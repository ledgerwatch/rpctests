package main

import (
	"crypto/rand"
	"crypto/tls"
	"flag"
	"fmt"
	"log"
	"net"
)

var (
	PORT = flag.String("port", "8080", "connections accepting port number")
	MODE = flag.String("mode", "local", "start server in mode: local | gcp")
)

func main() {
	flag.Parse()

	if *PORT == "" {
		_fatal(fmt.Errorf("'-port' flag is not set"))
	}

	if *MODE == "" {
		_fatal(fmt.Errorf("'-mode' flag is not set"))
	}

	address := fmt.Sprintf("127.0.0.1:%s", *PORT)

	var ln net.Listener

	if *MODE == "local" {
		cert, err := tls.LoadX509KeyPair("./ssl/certs/server.crt", "./ssl/certs/server-key.pem")
		if err != nil {
			_fatal(err)
		}
		config := tls.Config{Certificates: []tls.Certificate{cert}}
		config.Rand = rand.Reader
		ln, err = tls.Listen("tcp", address, &config)

		if err != nil {
			_fatal(err)
		}
	} else if *MODE == "gcp" {
		var err error
		ln, err = net.Listen("tcp", address)
		if err != nil {
			_fatal(err)
		}
	} else {
		_fatal(fmt.Errorf("unknown mode = %s", *MODE))
	}

	defer ln.Close()

	log.Println("Started listening: ", address)

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
