package main

import (
	"fmt"
)

const n int = 100
const m int = 5

var s2 [m][n]string

func main() {
	s2[0][0] = "a"
	s2[0][1] = "b"
	s2[1][0] = "c"
	s2[1][1] = "d"
	s2[2][0] = "e"
	s2[2][1] = "f"
	s2[3][0] = "g"
	s2[3][1] = "h"

	for i := 4; i >= 0; i-- {
		for j := 0; j < 2; j++ {
			fmt.Println(s2[i][j])
		}
	}
}
