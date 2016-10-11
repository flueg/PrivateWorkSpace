package main

import (
	"fmt"
)

func main() {
	aaa := "false"
	bbb := "1"

	if aaa != "false" || bbb != "0" {
		fmt.Println("true")
	} else {
		fmt.Println("false")
	}
}
