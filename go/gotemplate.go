package main

import (
	"fmt"
)

const c = "C"

var v int = 5

type T struct{}

func init() { // initialization of package
	fmt.Println("init")
}

func main() {
	var a int
	a = v
	fmt.Println(a)
	Func1() // ...  fmt.Println(a)
}

func (t T) Method1() { //...
}

func Func1() { // exported function Func1  //...
	fmt.Println("Func1")
}
