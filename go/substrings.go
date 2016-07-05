package main

import (
	"fmt"
)

func main() {
	s1 := "flueg is an asshold."
	s2 := "No, he isn't. You are"
	fmt.Printf("0-1%s\n", (s1 + s2)[0:1])
	fmt.Printf("0-30%s\n", (s1 + s2)[0:30])
	fmt.Printf("2-5%s\n", (s1 + s2)[2:5])
	fmt.Printf("2-end%s\n", (s1 + s2)[2:])

}
