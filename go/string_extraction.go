package main

import "fmt"

func main() {

    s := "hello"
    fmt.Println(s)
    c := []byte(s)
    c[0]='c'
    s2:= string(c) // s2 == "cello"
    fmt.Println(s2)
}
