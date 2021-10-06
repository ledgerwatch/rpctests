package main

import (
	"fmt"
	"os/exec"

	"github.com/racytech/qa_server/qa_common"
)

var (
	is_ok     = "OK"
	is_err    = "ERR"
	is_warn   = "WARN"
	is_server = "SERVER"

	init_color = "\033[0m"
	green      = "\033[32m"
	red        = "\033[31m"
	yellow     = "\033[33m"
	blue       = "\033[34m"

	// server = blue + ">>> " + init_color
)

var colors = map[string]string{
	is_ok:     green,
	is_err:    red,
	is_warn:   yellow,
	is_server: blue,
}

var responses = map[byte]string{
	qa_common.OK:          is_ok,
	qa_common.ERROR:       is_err,
	qa_common.WARN:        is_warn,
	qa_common.CONN_CLOSED: is_err,
}

func _println(kind string, msg string) {
	fmt.Println(colors[kind]+">>>"+init_color, msg)
}

func _print(kind string) {
	fmt.Print(colors[kind] + ">>> " + init_color)
}

func _print_response(kind string, msg string) {
	fmt.Println(colors[kind] + kind + init_color)
	fmt.Println(msg)
}

// func _print_err_resp() {
// 	fmt.Print(red + "ERROR: " + init_color)
// }

func _print_clear() {
	cmd := exec.Command("clear")
	bytes, err := cmd.Output()
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Print(string(bytes))
	}
}

func _print_help(ct *qa_common.CommandTable) {

	fmt.Println("----------------------------------")

	fmt.Println("colors:")
	fmt.Println(blue+"    >>>"+init_color, " - server response")
	fmt.Println(red+"    >>>"+init_color, " - error occurred")
	fmt.Println(green+"    >>>"+init_color, " - successful command execution")
	fmt.Println(yellow+"    >>>"+init_color, " - warning")
	fmt.Println()

	fmt.Println("command list:")
	for k, v := range ct.Commands {
		fmt.Printf("    %-20s - %s\n", k, ct.Descriptions[v])
	}

	fmt.Println("----------------------------------")

}
