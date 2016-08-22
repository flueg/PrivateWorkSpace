package main

import (
	"flag"
	"fmt"
)

func main() {
	f := flag.NewFlagSet("flag", flag.ExitOnError)
	f.Int("int", 0, "int flag with value")
	f.Int("int2", 0, "second int flag with value")
	f.String("string", "abb", "second int flag with value")

	visitor := func(a *flag.Flag) {
		fmt.Println(">", a.Name, "value=", a.Value)
	}

	fmt.Println("Visit All")
	f.VisitAll(visitor) // this will display the int2 flag

	fmt.Println("First visit")
	f.Visit(visitor) // no value assigned

	f.Parse([]string{"-int", "108"}) // visit flag set earlier and assign value

	fmt.Println("Second visit")
	f.Visit(visitor)
}
