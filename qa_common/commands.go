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
	TEST1
)

var (
	init_color = "\033[0m"
	green      = "\033[32m"
	red        = "\033[31m"
	yellow     = "\033[33m"
	blue       = "\033[34m"
)

type CommandTable struct {
	commands     map[string]int
	Descriptions map[string]string
	exec_cmd     map[int]*exec.Cmd
	exec_file    map[int]string
}

func NewCommandTable() *CommandTable {
	var cmds = map[string]int{
		"help":  HELP,
		"ping":  PING,
		"clear": CLEAR,
		"exit":  EXIT,
		"quit":  EXIT,
		"test1": TEST1,
	}

	var descriptions = map[string]string{
		"help":  "print all available commands and color meanings",
		"ping":  "command for testing communication",
		"clear": "clear the terminal",
		"exit":  "quit the program",
		"test1": "just testing...",
	}

	return &CommandTable{commands: cmds, Descriptions: descriptions}
}

func (ct *CommandTable) AddExecCmd() *CommandTable {

	var exec_file = map[int]string{
		TEST1: "./run.sh",
	}

	var exec_cmd = map[int]*exec.Cmd{
		TEST1: exec.Command(exec_file[TEST1]),
	}

	ct.exec_cmd = exec_cmd
	ct.exec_file = exec_file

	return ct
}

func (ct *CommandTable) Reset(cmd_int int) {
	ct.exec_cmd[cmd_int] = exec.Command(ct.exec_file[cmd_int])
}

func (ct *CommandTable) What(command string) int {
	if val, ok := ct.commands[command]; ok {
		return val
	}
	return 0
}
