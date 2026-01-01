{ config, pkgs, lib, ... }:

let
  # --- 1. The Go Control Server ---
  # A standalone Go binary that handles HTTP uploads and MPV IPC
  controlBinary = pkgs.writers.writeGoBin "mpv-controller" {} ''
    package main

    import (
    	"encoding/json"
    	"fmt"
    	"io"
    	"net"
    	"net/http"
    	"os"
    	"path/filepath"
    )

    const (
    	ipcPath      = "/tmp/mpv-socket"
    	uploadFolder = "/var/lib/kiosk-media"
    	videoPath    = uploadFolder + "/current.mp4"
    )

    // Command represents the JSON structure MPV expects
    type Command struct {
    	Command []string `json:"command"`
    }

    const html = `
    <!doctype html>
    <title>Pi Kiosk (Go)</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      body { font-family: sans-serif; padding: 2rem; text-align: center; background: #222; color: #fff; }
      .btn { display: block; width: 100%; padding: 15px; margin: 10px 0; font-size: 1.2rem; cursor: pointer; border: none; border-radius: 4px; }
      .upload { background: #4CAF50; color: white; }
      .stop { background: #f44336; color: white; }
      input { margin-bottom: 20px; color: white; }
    </style>
    <h1>Orange Pi Kiosk</h1>
    <form method="post" enctype="multipart/form-data">
      <input type="file" name="video" accept="video/*" required>
      <button class="btn upload" type="submit">Upload & Play</button>
    </form>
    <form action="/stop" method="post">
      <button class="btn stop">Stop Playback</button>
    </form>
    `

    func main() {
    	// Ensure upload directory exists
    	if err := os.MkdirAll(uploadFolder, 0755); err != nil {
    		fmt.Printf("Error creating dir: %v\n", err)
    	}

    	http.HandleFunc("/", handleIndex)
    	http.HandleFunc("/stop", handleStop)

    	fmt.Println("Starting server on :8080...")
    	if err := http.ListenAndServe(":8080", nil); err != nil {
    		panic(err)
    	}
    }

    func handleIndex(w http.ResponseWriter, r *http.Request) {
    	if r.Method != http.MethodPost {
    		w.Header().Set("Content-Type", "text/html")
    		fmt.Fprint(w, html)
    		return
    	}

    	// Limit upload size to 500MB (adjust as needed)
    	r.ParseMultipartForm(500 << 20)

    	file, _, err := r.FormFile("video")
    	if err != nil {
    		http.Error(w, "Error retrieving file", http.StatusBadRequest)
    		return
    	}
    	defer file.Close()

    	// Save the file
    	dst, err := os.Create(videoPath)
    	if err != nil {
    		http.Error(w, "Error saving file", http.StatusInternalServerError)
    		return
    	}
    	defer dst.Close()

    	if _, err := io.Copy(dst, file); err != nil {
    		http.Error(w, "Error writing file", http.StatusInternalServerError)
    		return
    	}

    	// Tell MPV to play
    	if err := sendIPC([]string{"loadfile", videoPath}); err != nil {
    		fmt.Fprintf(w, "%s<p>Upload success, but MPV IPC failed: %v</p>", html, err)
    		return
    	}

    	fmt.Fprintf(w, "%s<p>Playing...</p>", html)
    }

    func handleStop(w http.ResponseWriter, r *http.Request) {
    	if r.Method == http.MethodPost {
    		sendIPC([]string{"stop"})
    		fmt.Fprintf(w, "%s<p>Stopped.</p>", html)
    	} else {
    		http.Redirect(w, r, "/", http.StatusSeeOther)
    	}
    }

    func sendIPC(args []string) error {
    	conn, err := net.Dial("unix", ipcPath)
    	if err != nil {
    		return err
    	}
    	defer conn.Close()

    	cmd := Command{Command: args}
    	data, err := json.Marshal(cmd)
    	if err != nil {
    		return err
    	}

    	_, err = conn.Write(append(data, '\n'))
    	return err
    }
  '';

in {
  # --- System Basics ---
  networking.hostName = "orangepi-kiosk";
  networking.firewall.allowedTCPPorts = [ 8080 22 ];
  
  users.users.kiosk = {
    isNormalUser = true;
    extraGroups = [ "video" "audio" ];
  };

  # --- 2. Cage (Compositor) Service ---
  services.cage = {
    enable = true;
    user = "kiosk";
    program = pkgs.writeShellScript "start-mpv" ''
      # Start MPV in idle mode, listening on IPC socket
      ${pkgs.mpv}/bin/mpv --idle --force-window --input-ipc-server=/tmp/mpv-socket --hwdec=auto --fs
    '';
  };

  # --- 3. Go Web Control Service ---
  systemd.services.mpv-web-controller = {
    description = "Go Web Interface for MPV Kiosk";
    after = [ "cage.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "kiosk";
      ExecStart = "${controlBinary}/bin/mpv-controller";
      Restart = "always";
    };
  };

  services.openssh.enable = true;
  system.stateVersion = "24.05";
}
