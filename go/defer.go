/*
 * "defer" allows us to guarantee that certain clean-up tasks are performed
 * before we return from a function
 */
package main

import "fmt"

func main() {
	Function1()
	Function3()
}

func Function1() {
	a()
	f()
	println()
	fmt.Printf("In Function1 at the top\n")
	// "defer" will call the specified function finally.
	defer Function2()
	fmt.Printf("In Function1 at the bottom!\n")
}

func Function2() {
	fmt.Printf("Function2: Deferred until the end of the calling function!\n")
}

func Function3() {
	fmt.Printf("Function3: at the main bottom.")
}

func a() {
	i := 0
	defer fmt.Println(i)
	i++
	return
}

func f() {
	for i := 0; i < 5; i++ {
		defer fmt.Printf("%d ", i)
	}
}
