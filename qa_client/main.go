package main

import (
	"crypto/tls"
	"flag"
	"log"
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

	cert, err := tls.LoadX509KeyPair("./ssl/certs/client.crt", "./ssl/certs/client-key.pem")
	if err != nil {

		_println(is_err, err.Error())
		return
	}

	config := tls.Config{Certificates: []tls.Certificate{cert}, InsecureSkipVerify: true}
	conn, err := tls.Dial("tcp", address, &config)

	if err != nil {
		log.Fatal(err)
		return
	}

	defer conn.Close()

	handle_connection(conn)
}
