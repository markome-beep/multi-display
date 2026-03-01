package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"
	"time"

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
func (a *App) sendToAll(videoCommand string, delay int64) {
	var wg sync.WaitGroup

	runtime.EventsEmit(a.ctx, "Disable_UI")

	for _, host := range a.hosts {
		target := time.Now().Unix() + delay // executes command in 5 seconds
		remoteCmd := fmt.Sprintf(`
			TARGET=%d
			while [ "$(date +%%s)" -lt "$TARGET" ]; do :; done
			echo '%s' | socat - /tmp/mpv-socket
			`, target, videoCommand)
		wg.Add(1)
		go func() {

			runtime.EventsEmit(a.ctx, "Upload_Started", host)
			cmd := exec.Command(
				"ssh",
				"-o",
				"ConnectTimeout=10",
				host,      //this string is of the form username@hostname
				remoteCmd, //assume all sockets are in same location)
			)

			if err := cmd.Run(); err != nil {
				runtime.EventsEmit(a.ctx, "Upload_Failed", host)
			} else {
				runtime.EventsEmit(a.ctx, "Upload_Success", host)
			}
			wg.Done()
		}()
	}
	go func() {
		wg.Wait()
		runtime.EventsEmit(a.ctx, "Enable_UI")
	}()
}

// Pause videos
func (a *App) PauseAll() {
	a.sendToAll(`{"command":["set_property","pause",true]}`, 5)
}

// Play videos
func (a *App) PlayAll() {
	a.sendToAll(`{"command":["set_property","pause",false]}`, 5)
}

// Seek to a specific time in all videos (in seconds)
func (a *App) SeekAll(timeInSeconds int) {
	a.sendToAll(fmt.Sprintf(`{ "command": ["seek", %d, "absolute-percent"] }`, timeInSeconds), 0)
}

func (a *App) LoadVideoAll() {
	a.Sync10()
	a.sendToAll(`{ "command": ["loadfile", "/home/movie/vid.mp4"] }`, 0)
}

// Wrapper to send commands to all registered pi's
func (a *App) RebootAll() {
	var wg sync.WaitGroup
	runtime.EventsEmit(a.ctx, "Disable_UI")

	for _, host := range a.hosts {
		remoteCmd := "sudo -S reboot"
		wg.Add(1)
		go func() {
			runtime.EventsEmit(a.ctx, "Upload_Started", host)
			cmd := exec.Command(
				"ssh",
				"-o",
				"ConnectTimeout=10",
				host,      //this string is of the form username@hostname
				remoteCmd, //assume all sockets are in same location)
			)
			cmd.Stdin = strings.NewReader("movie123\n")

			cmd.Run()
			runtime.EventsEmit(a.ctx, "Upload_Clear", host)
			wg.Done()
		}()
	}
	go func() {
		wg.Wait()
		runtime.EventsEmit(a.ctx, "Enable_UI")
	}()
}

func (a *App) Sync10() {
	host := "movie@192.168.1.10"

	remoteCmd := "sudo timedatectl set-ntp false"
	cmd := exec.Command(
		"ssh",
		"-o",
		"ConnectTimeout=10",
		host,      //this string is of the form username@hostname
		remoteCmd, //assume all sockets are in same location)
	)
	cmd.Stdin = strings.NewReader("movie123\n")

	cmd.Run()

	time := time.Now().Format("2006-01-02 15:04:05")
	remoteCmd = fmt.Sprintf(`sudo -S timedatectl set-time "%s"`, time)
	cmd = exec.Command(
		"ssh",
		"-o",
		"ConnectTimeout=10",
		host,      //this string is of the form username@hostname
		remoteCmd, //assume all sockets are in same location)
	)
	cmd.Stdin = strings.NewReader("movie123\n")

	cmd.Run()
}

// May want to test connection to pi's
