package main

import "fmt"

func main() {
	var num1 int = 100

	switch num1 {
	case 98, 99:
		fmt.Println("It’s equal to 98")
	case 100:
		fmt.Println("It’s equal to 100")
	default:
		fmt.Println("It’s not equal to 98 or 100")
	}

	var num2 int = 7

	switch {
	case num2 < 0:
		fmt.Println("Number is negative")
	case num2 > 0 && num2 < 10:
		fmt.Println("Number is between 0 and 10")
	default:
		fmt.Println("Number is 10 or greater")
	}

}
