package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"strings"

	"github.com/racytech/qa_server/qa_common"
)

func handle_connection(conn net.Conn) {

	cmd_table := qa_common.NewCommandTable()

	_println(is_ok, "Connected to the server. Print 'help' to see available list of operations.")

	arrow_state := is_ok
	qa_common.Read_qa_scripts() // prepare all scripts in qa_scripts directory
	for {

		reader := bufio.NewReader(os.Stdin)
		_print(arrow_state)
		input, _ := reader.ReadString('\n')
		command := strings.TrimSpace(input)

		if len(command) > 0 {

			cmd_num := cmd_table.What(command)

			if cmd_num != 0 {
				// perform checks if command can be executed on client's machine
				if cmd_num == qa_common.CLEAR {
					_print_clear()
					continue
				}

				if cmd_num == qa_common.HELP {
					_print_help(cmd_table)
					continue
				}
			}

			// e.g ["sudo", "apt", "install", "some_software"]
			all_input := strings.Split(command, " ")

			// check the first command in command sequence
			// e.g in command 'sudo apt install some_software'
			// check if first entry-'sudo' is disallowed
			is_disallowed := qa_common.Check_disallowed(all_input[0])

			if is_disallowed {
				_println(is_err, fmt.Sprintf("'%s' is disallowed command", all_input[0]))
				arrow_state = is_err
				continue
			}

			// // check if command is to execute a script
			// if val, ok := qa_common.Valid_scripts[all_input[0]]; ok {
			// 	all_input[0] = val
			// 	command = strings.Join(all_input, " ")
			// 	fmt.Println(command)
			// }

			_, err := fmt.Fprintf(conn, command+"\n")
			if err != nil {
				fmt.Println(err)
				return
			}

			resp, err := bufio.NewReader(conn).ReadString(qa_common.END_OF_MESSAGE)
			if err != nil {
				if err.Error() == "EOF" {
					_println(is_err, "Connection closed... exiting...")
				} else {
					_println(is_err, fmt.Sprintf("Error: %s", err))
				}
				return
			}

			kind, msg := qa_common.DecodeResponse(resp)
			if kind == qa_common.CONN_CLOSED {
				_println(is_err, "Connection closed... exiting...")
				return
			}

			_print(is_server)
			msg = strings.TrimSpace(msg)
			_print_response(responses[kind], msg)

			arrow_state = responses[kind]
		}

	}
}
