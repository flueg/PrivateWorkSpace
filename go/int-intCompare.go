package main

import "fmt"

func main() {
	a := 1
	b := 10
	var aa int = 1
	var bb int = 10
	if a != aa || b != bb {
		fmt.Printf("[%d]->[%d],[%d]->[%d] Not equal.\n", a, aa, b, bb)
	} else {
		fmt.Printf("[%d]->[%d],[%d]->[%d] Equal.\n", a, aa, b, bb)
	}

}
