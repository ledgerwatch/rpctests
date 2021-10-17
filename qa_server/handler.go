package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/racytech/qa_server/qa_common"
)

func handle_connection(conn net.Conn) {

	conn.SetDeadline(time.Time{}) // zero value?

	defer conn.Write(qa_common.NewResponse([]byte("connection closed"), qa_common.CONN_CLOSED))

	defer conn.Close()

	qa_common.Read_qa_scripts()
	for {

		data, err := bufio.NewReader(conn).ReadString('\n')

		if err != nil {
			conn.Write(
				qa_common.NewResponse([]byte(err.Error()), qa_common.ERROR))
			return
		}

		data = strings.TrimSpace(data)

		all_input := strings.Split(data, " ")

		is_script := false
		script_name := ""  // e.g "./qa_scripts/some_script.sh"
		command_name := "" // only for cli provided scripts ("made up" comands)
		// check if command is to execute a cli provided script
		if val, ok := qa_common.Valid_scripts[all_input[0]]; ok {
			is_script = true
			script_name = val
			command_name = all_input[0] // kill_erigon, rpctest_replay
			// all_input[0] = val
			// data = strings.Join(all_input, " ")

			// data_bytes = append(data_bytes, []byte("Data after:"+data+"\n")...)

			// conn.Write(
			// 	qa_common.NewResponse(data_bytes, qa_common.ERROR))
			// continue
		}

		if is_script {
			// now instead of having ["rpctest_replay", "arg"]
			// there is ["./qa_scripts/rpctest_replay.sh", "arg"]
			all_input[0] = script_name
			data = strings.Join(all_input, " ")
			fmt.Println(data, command_name, len(all_input))
			if command_name == "rpctest_replay" {
				fmt.Println("GOT HERE")
				if len(all_input) >= 2 {
					cmd := exec.Command(all_input[0], all_input[1])

					cmd.Stdout = os.Stdout

					err := cmd.Start()
					if err != nil {
						resp := qa_common.NewResponse([]byte(err.Error()), qa_common.ERROR)
						conn.Write(resp)
					} else {
						cmd.Wait()
						msg := "Started \"rpctest replay\". Check log files."
						resp := qa_common.NewResponse([]byte(msg), qa_common.OK)
						conn.Write(resp)

					}

				} else {
					resp := qa_common.NewResponse([]byte("Branch to checkout is not provided. Exiting..."), qa_common.ERROR)
					conn.Write(resp)
				}

				continue
			}

			// other scripts that require special execution can go here
		}

		cmd := exec.Command("bash", "-c", data)

		var output []byte
		if output, err = cmd.CombinedOutput(); err != nil {
			err_bytes := []byte(err.Error())
			if output != nil {
				output = append(output, err_bytes...)
				conn.Write(
					qa_common.NewResponse(output, qa_common.ERROR))
			} else {
				conn.Write(
					qa_common.NewResponse(err_bytes, qa_common.ERROR))
			}

		} else {
			conn.Write(qa_common.NewResponse(output, qa_common.OK))
		}

	}

}
