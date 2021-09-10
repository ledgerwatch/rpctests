package main

import (
	"flag"
	"fmt"
	"log"
	"net"
)

var (
	PORT = flag.String("port", "8080", "connections accepting port number")
)

func main() {
	flag.Parse()

	if *PORT == "" {
		_fatal(fmt.Errorf("'-port' flag is not set"))
	}

	address := fmt.Sprintf("0.0.0.0:%s", *PORT)

	ln, err := net.Listen("tcp", address)
	if err != nil {
		_fatal(err)
	}
	defer ln.Close()

	for {

		log.Println("Waiting for connection...")

		conn, err := ln.Accept()
		if err != nil {
			// error accpeting connection
			// TODO

			fmt.Println("Error: ", err.Error())
		} else {
			log.Printf("Received connection: %s\n", conn.RemoteAddr().String())
			handle_connection(conn)
		}

	}

}

func _fatal(err error) {
	// TODO
	log.Fatalln("Error: ", err)
}
