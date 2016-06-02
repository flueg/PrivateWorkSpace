package main

import (
	"fmt"
	"time"
)

func main() {
	go func1()
	go func2()
	// the main function will exit right away without waiting goroutine being scheduled to run.
	//time.Sleep(10 * time.Millisecond)
}

func func1() {
	for {
		fmt.Println("here1")
	}

}

func func2() {
	for {
		fmt.Println("here2")
	}
}
