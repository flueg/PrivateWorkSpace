package main

import (
	"fmt"
)

var Data map[string][]string

func AAA() {
	Data = make(map[string][]string, 10)
}

func InitMaps(key string) {
	st := []string{"this is not funny!"}
	Data[key] = st
}

func Append(key string) {
	if ss, ok := Data[key]; ok {
		Data[key] = append(ss, " Hey! Appending here I'm.")
	}
}

func main() {
	AAA()
	key := "test"
	if ss, ok := Data[key]; ok {
		fmt.Printf("Get value: %v", ss)
	} else {
		fmt.Printf("No value.\n")
		InitMaps(key)
	}

	if ss, ok := Data[key]; ok {
		fmt.Printf("Get value: %v\n", ss)
		fmt.Printf("Len:%d\n", len(ss))
	}

	Append(key)

	if ss, ok := Data[key]; ok {
		fmt.Printf("Get value after appended: %v\n", ss)
		fmt.Printf("Len:%d\n", len(ss))
	}
}
