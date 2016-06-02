package main

import (
	"fmt"
)

var c = make(chan int, 2)

func main() {
	go func1()
	go func2()
	fmt.Println("channel 1:", <-c)
	fmt.Println("channel 2:", <-c)
	fmt.Println("ok")
}

func func1() {
	fmt.Println("here1")
	c <- 1
}

func func2() {
	fmt.Println("here2")
	c <- 2
}
