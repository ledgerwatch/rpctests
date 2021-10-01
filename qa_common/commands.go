package qa_common

import (
	"os/exec"
)

/* ------------------------------------------ */

const (
	HELP int = 0x01 + iota
	CLEAR
	EXIT
	RPCTEST_REPLAY
)

const SCRIPTS_PATH = "./qa_scripts/"

type CommandTable struct {
	Commands     map[string]int
	Descriptions map[int]string
	exec_cmd     map[int]*exec.Cmd
	exec_file    map[int]string
}

func NewCommandTable() *CommandTable {

	var cmds = map[string]int{
		"help":                HELP,
		"clear":               CLEAR,
		"exit":                EXIT,
		"quit":                EXIT,
		"./rpctest_replay.sh": RPCTEST_REPLAY,
	}

	var descriptions = map[int]string{
		HELP:           "print all available commands and color meanings",
		CLEAR:          "clear the terminal",
		EXIT:           "quit the program",
		RPCTEST_REPLAY: "run rpc replay tests",
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
