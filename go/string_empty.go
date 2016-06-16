package main

import (
	"fmt"
)

func main() {
	// ss will be initialized as empty "" by default
	var ss string
	if ss == "" {
		fmt.Println("string ss is empty")
	}
	ss = ""
	if ss == "" {
		fmt.Println("string ss is empty neither")
	}
	ss = "flueg"
	fmt.Printf("string ss is %s\n", ss)
}
