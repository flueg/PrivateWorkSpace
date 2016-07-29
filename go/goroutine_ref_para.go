package main

import (
	"fmt"
	"time"
	//"sync"
)

//var wg sync.WaitGroup
var timeout chan int
var kk chan int

func Go(i, j *int) {
	*j = *j + *i
	fmt.Printf("i,j is %d,%d\n", *i, *j)
	kk <- *i
}

func Timeout() {
	time.Sleep(100 * time.Millisecond)
	timeout <- 1

}

func main() {
	timeout = make(chan int)
	kk = make(chan int, 5)
	i, j := 0, 0
	go Timeout()
	for i = 0; i < 10; i++ {
		j = i + 1
		// Note that:
		// Don't invoke function directly here like this: go Go(&i, &j)
		// Since variable i,j in loop for might be changed to 10 when the go rontine begins to run.
		// So we need a anomymous function to make the variable locally.
		go func(i, j int) {
			Go(&i, &j)
		}(i, j)
		fmt.Printf("now i,j is %d,%d\n", i, j)
	}

	for {
		// select is not a deadloop
		select {
		case <-timeout:
			fmt.Println("go routine timeout!!")
			return
		case ff := <-kk:
			fmt.Printf("Go routine %d finished.\n", ff)
		}
	}
	//fmt.Printf("now i,j is %d,%d\n", i, j)
}
