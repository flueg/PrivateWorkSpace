package main

import (
	"fmt"
)

func main() {
	s1 := "flueg is an asshold."
	s2 := "No, he isn't. You are"
	fmt.Printf("%s", (s1 + s2)[0:30])

}
