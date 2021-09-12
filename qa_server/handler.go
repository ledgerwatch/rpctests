package main

import (
	"bufio"
	"net"
	"os/exec"
	"strings"

	"github.com/racytech/qa_server/qa_common"
)

func handle_connection(conn net.Conn) {
	defer conn.Write(qa_common.NewResponse([]byte("connection closed"), qa_common.CONN_CLOSED))

	defer conn.Close()

	for {

		data, err := bufio.NewReader(conn).ReadString('\n')

		if err != nil {
			conn.Write(
				qa_common.NewResponse([]byte(err.Error()), qa_common.ERROR))
			return
		}

		data = strings.TrimSpace(data)

		// TODO double check for disallowed operations

		// if command is to run erigon or rpcdaemon
		//   check if erigon or rpcdaemon already running
		//   if erigon or rpcdaemon already running
		//	 ask if its required to shut it down
		//	 if its required, send signal to shut the process down
		//   else dont do anything, continue to listen for commands
		//
		// 	 else (if erigon or rpcdaemon not running)
		//   execute the script in separate thread, with receiving chan
		//	 let the user know that commands is started or failed
		//   continue to listen for commands

		// if command is not related to erigon or rpcdaemon
		// e.g cd erigon && git checkout <branch>
		// e.g cd erigon && git fetch origin
		// etc
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
