package main

import (
	"fmt"
	"time"
)

func main() {
	go func1()
	go func2()
	select {}
	fmt.Println("Deadlock!")
}

func func1() {
	for {
		fmt.Println("here1")
		time.Sleep(10 * time.Minute)
	}

}

func func2() {
	for {
		fmt.Println("here2")
		time.Sleep(10 * time.Minute)
	}
}
