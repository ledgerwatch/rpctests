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
