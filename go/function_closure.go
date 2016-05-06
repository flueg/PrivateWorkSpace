package main

import "fmt"

func main() {
	var f = Adder()
	fmt.Print(f(1), "-")
	fmt.Print(f(20), "-")
	fmt.Print(f(300))
}

func Adder() func(int) int {
	// By declaring a function closure, we can let the variable x keep increasing continuously.
	var x int
	return func(delta int) int {
		x += delta
		return x
	}
}
