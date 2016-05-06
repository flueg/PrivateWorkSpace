package main

import (
	"fmt"
	"os"
	"runtime"
)

func test() {

}

func main() {
	fmt.Printf("%s\n", runtime.Version())
	var goos string = os.Getenv("GOOS")
	fmt.Printf("The operating system is: %s\n", goos)
	path := os.Getenv("PATH")
	fmt.Printf("Path is %s\n", path)
}
