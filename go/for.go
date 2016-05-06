package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Printf("This is the %d iteration\n", i)
	}

	for i := 0; i < 2; i++ {
		for j := 0; j < 3; j++ {
			println(j)
		}
	}

}
