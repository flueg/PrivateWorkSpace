//
// Hello World Zeromq server
//
// Author: Aaron Raddon   github.com/araddon
// Requires: http://github.com/alecthomas/gozmq
//
package main

import (
	"fmt"
	zmq "github.com/pebbe/zmq4"
	"time"
)

func main() {
	context, _ := zmq.NewContext()
	socket, _ := context.NewSocket(zmq.REP)
	defer context.Term()
	defer socket.Close()
	socket.Bind("tcp://*:5555")

	// Wait for messages
	for {
		msg, _ := socket.Recv(0)
		println("Received ", string(msg))

		// do some fake "work"
		time.Sleep(time.Second)

		// send reply back to client
		reply := fmt.Sprintf("World")
		socket.Send(reply, 0)
	}
}
