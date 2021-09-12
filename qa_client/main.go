package main

import (
	"flag"
	"net"
)

var (
	ADDRESS = flag.String("address", "", "server's IP address and a port number")
)

func main() {

	flag.Parse()

	address := *ADDRESS
	if address == "" {
		_println(is_err, "'-address' flag is not set")
		return
	}

	conn, err := net.Dial("tcp", address)
	if err != nil {
		_println(is_err, err.Error())
		return
	}
	defer conn.Close()

	handle_connection(conn)
}
