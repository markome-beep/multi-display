package main

import (
	"context"
	"fmt"
	"os/exec"
)

// App struct
type App struct {
	ctx context.Context
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// Greet returns a greeting for the given name
func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

// Video Controls

// hostnames of pi's (replace with IPs, or use mDNS for auto resolution)
var hosts = []string{
	"movie@192.168.1.10",
	"movie@192.168.1.11",
	"movie@192.168.1.12",
	"movie@192.168.1.13",
}

// Wrapper to send commands to all registered pi's
func sendToAll(videoCommand string) {
	for _, host := range hosts {
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
	sendToAll(`{"command":["set_property","pause",true]}`)
}

// Play videos
func (a *App) PlayAll() {
	sendToAll(`{"command":["set_property","pause",false]}`)
}

// Seek to a specific time in all videos (in seconds)
func (a *App) SeekAll(timeInSeconds int) {
	sendToAll(fmt.Sprintf(`{ "command": ["seek", %d, "absolute"] }`, timeInSeconds))
}

// May want to test connection to pi's
