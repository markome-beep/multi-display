package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"

	"github.com/wailsapp/wails/v2/pkg/runtime"
)

// App struct
type App struct {
	ctx   context.Context
	hosts []string
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
	a.hosts = []string{
		"movie@192.168.1.10",
		"movie@192.168.1.11",
		"movie@192.168.1.12",
		"movie@192.168.1.13",
	}
}

// Replace this later with something that is not hardcoded
func (a *App) GetIPs(i int) []string {
	return a.hosts
}

// Video Controls

// hostnames of pi's (replace with IPs, or use mDNS for auto resolution)

func (a *App) ProcessFile(filePath string, host string) {
	fmt.Println(filePath)
	if filePath == "" {
		fmt.Println("Empty")
		return
	}
	go func() {
		runtime.EventsEmit(a.ctx, "Upload_Started", host)
		cmd := exec.Command(
			"scp",
			filePath,
			host+":/home/movie/vid.mp4",
		)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			runtime.EventsEmit(a.ctx, "Upload_Failed", host)
		} else {
			runtime.EventsEmit(a.ctx, "Upload_Success", host)
		}
	}()
}

func (a *App) DebugPrint(s string) {
	fmt.Println(s)
}

func (a *App) FileDialog(binName string) {
	file, err := runtime.OpenFileDialog(a.ctx, runtime.OpenDialogOptions{
		Title: "Upload file to display",
		Filters: []runtime.FileFilter{
			{DisplayName: "Video Files", Pattern: "*.mp4"},
			{DisplayName: "All Files", Pattern: "*"},
		},
	})
	if err != nil {
		fmt.Println(err)
		return
	}
	a.ProcessFile(file, binName)
}

// Wrapper to send commands to all registered pi's
func (a *App) sendToAll(videoCommand string) {
	for _, host := range a.hosts {
		// check for 1 command per pi
		remoteCmd := "echo '" + videoCommand + "' | socat - /tmp/mpv-socket"
		go func() {
			cmd := exec.Command(
				"ssh",
				host,      //this string is of the form username@hostname
				remoteCmd, //assume all sockets are in same location)
			)
			cmd.Run()
		}()
	}

	// ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	// defer cancel()

	// cmd := exec.CommandContext(ctx,
	// 	"ssh",
	// 	"pi@"+pi,
	// 	"echo '"+cmdJSON+"' | socat - /tmp/mpv-socket",
	// )

	// if err := cmd.Run(); err != nil {
	// 	log.Printf("[%s] command failed: %v", pi, err)
	// }
}

// Pause videos
func (a *App) PauseAll() {
	a.sendToAll(`{"command":["set_property","pause",true]}`)
}

// Play videos
func (a *App) PlayAll() {
	a.sendToAll(`{"command":["set_property","pause",false]}`)
}

// Seek to a specific time in all videos (in seconds)
func (a *App) SeekAll(timeInSeconds int) {
	a.sendToAll(fmt.Sprintf(`{ "command": ["seek", %d, "absolute"] }`, timeInSeconds))
}

// May want to test connection to pi's
