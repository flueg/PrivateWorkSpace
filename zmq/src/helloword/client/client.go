//
// Hello World Zeromq Client
//
// Author: Aaron Raddon   github.com/araddon
// Requires: http://github.com/alecthomas/gozmq
//
package main

import (
	"fmt"
	zmq "github.com/alecthomas/gozmq"
)

func main() {
	context, _ := zmq.NewContext()
	socket, _ := context.NewSocket(zmq.REQ)
	defer context.Term()
	defer socket.Close()

	fmt.Printf("Connecting to hello world server…")
	socket.Connect("tcp://localhost:5555")

	for i := 0; i < 10; i++ {
		// send hello
		msg := fmt.Sprintf("Hello %d", i)
		socket.Send(msg, 0)
		println("Sending ", msg)

		// Wait for reply:
		reply, _ := socket.Recv(0)
		println("Received ", string(reply))
	}
}
