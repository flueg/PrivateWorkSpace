package main

import (
	"flag"
	"fmt"
	"os"
	"strconv"
)

var goal int

func primetask(c chan int) {
	p := <-c
	if p > goal {
		os.Exit(0)
	}
	fmt.Println(p)
	nc := make(chan int)
	go primetask(nc)
	for {
		i := <-c
		if p*p > i {
			//fmt.Printf("root %d less than %d\n", i, p)
			nc <- i
			continue
		}
		if i%p == 0 {
			//fmt.Printf("%d devied by %d\n", i, p)
			continue
		}
		nc <- i
	}
}

func main() {
	flag.Parse()
	args := flag.Args()
	if args != nil && len(args) > 0 {
		var err error
		goal, err = strconv.Atoi(args[0])
		if err != nil {
			goal = 100
		}
	} else {
		goal = 100
	}
	fmt.Println("goal=", goal)
	c := make(chan int)
	go primetask(c)
	if goal >= 2 {
		fmt.Println(2)
	}
	for i := 3; ; i += 2 {
		c <- i
	}
}
