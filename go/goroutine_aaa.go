package main

import "fmt"

var c = []chan int{}

func hello(num int) {
	fmt.Println("Hello: ", num)
	//<-c[num]
}

func main() {

	COUNT := 50
	for i := 0; i != COUNT; i++ {
		c = append(c, make(chan int))
	}
	for i := 0; i != COUNT-1; i++ {
		go func() {
			hello(i)
			<-c[i]
		}()
		//go hello(i)
	}

	for i := 0; i != COUNT; i++ {
		c[i] <- 0
	}
	fmt.Println("World")
}
