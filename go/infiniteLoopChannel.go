package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int, 1)
	for {
		select {
		case ch <- 0:
		case ch <- 1:
		}

		// 1 seconds = 1000 * time.Millisecond
		time.Sleep(100 * time.Millisecond)
		i := <-ch
		fmt.Println("Value received:", i)
	}
}
