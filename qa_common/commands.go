package qa_common

import (
	"os/exec"
)

/* ------------------------------------------ */

const (
	HELP int = 0x01 + iota
	PING
	CLEAR
	EXIT
	START_ERIGON
	START_RPCDAEMON
	KILL_ERIGON
	KILL_RPCDAEMON
)

var (
	init_color = "\033[0m"
	green      = "\033[32m"
	red        = "\033[31m"
	yellow     = "\033[33m"
	blue       = "\033[34m"
)

type CommandTable struct {
	Commands     map[string]int
	Descriptions map[int]string
	exec_cmd     map[int]*exec.Cmd
	exec_file    map[int]string
}

func NewCommandTable() *CommandTable {
	var cmds = map[string]int{
		"help":            HELP,
		"ping":            PING,
		"clear":           CLEAR,
		"exit":            EXIT,
		"quit":            EXIT,
		"start_erigon":    START_ERIGON,
		"start_rpcdaemon": START_RPCDAEMON,
		"kill_erigon":     KILL_ERIGON,
		"kill_rpcdaemon":  KILL_RPCDAEMON,
	}

	var descriptions = map[int]string{
		HELP:            "print all available commands and color meanings",
		PING:            "command for testing communication",
		CLEAR:           "clear the terminal",
		EXIT:            "quit the program",
		START_ERIGON:    "start erigon process",
		START_RPCDAEMON: "start rpcdaemon process",
		KILL_ERIGON:     "kill erigon process",
		KILL_RPCDAEMON:  "kill rpcdaemon process",
	}

	return &CommandTable{Commands: cmds, Descriptions: descriptions}
}

func (ct *CommandTable) AddExecCmd() *CommandTable {

	var exec_file = map[int]string{}

	var exec_cmd = map[int]*exec.Cmd{}

	ct.exec_cmd = exec_cmd
	ct.exec_file = exec_file

	return ct
}

func (ct *CommandTable) Reset(cmd_int int) {
	ct.exec_cmd[cmd_int] = exec.Command(ct.exec_file[cmd_int])
}

func (ct *CommandTable) What(command string) int {
	if val, ok := ct.Commands[command]; ok {
		return val
	}
	return 0
}
