package main

import "fmt"

func main() {
	map1 := make(map[int]float32)
	map1[3] = 3.0
	map1[2] = 2.0
	map1[1] = 1.0
	//The Way to Go
	map1[4] = 4.0
	// Elements in map are not key-ordered.
	for key, value := range map1 {
		fmt.Printf("key is: %d - value is: %f\n", key, value)
	}
}
