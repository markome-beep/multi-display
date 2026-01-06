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
var pis = []string{
	"pi1.local",
	"pi2.local",
	"pi3.local",
	// add or subtract as needed
}

// Wrapper to send commands to all registered pi's
func sendToAll(cmd string) {
	for _, pi := range pis {
		exec.Command(
			"ssh",
			"pi@"+pi, //this string is of the form username@hostname
			"echo '"+cmd+"' | socat - /tmp/mpv-socket", //assume all sockets are in same location
		).Start() // Start() does not block, do we want to wait until we know if command succeeded?
	}
}

// Pause video
func (a *App) PauseAll() {
	sendToAll(`{"command":["set_property","pause",true]}`)
}

// Play video
func (a *App) PlayAll() {
	sendToAll(`{"command":["set_property","pause",false]}`)
}

// May want to test connection to pi's
