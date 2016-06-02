package main

import (
	"fmt"
	"sync"
)

var c = make(chan int)
var lock sync.Mutex

func hello(num int) {
	lock.Lock()
	defer lock.Unlock()
	c <- num
	fmt.Println("hello: ", num)
}

func main() {

	COUNT := 50
	for i := 0; i < COUNT; i++ {
		go hello(i)
	}

	for i := 0; i < COUNT; i++ {
		fmt.Println("Main: ", <-c)
	}
	fmt.Println("World")
}
