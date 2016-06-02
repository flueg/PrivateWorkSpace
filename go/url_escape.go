package main

import (
	"fmt"
	"net/url"
)

func main() {
	ss := "cWAkNlT90tQzvBzO4D/wNBpIddvQRMKHMMF6o5UlKiw6C3936zK/ 9fC1L2WVNB0qjp9x dvB7pOf2v1s9rYGsoZoeK5CIxRTJxaHIH/F82YyOyaejwwGMO1rtDc3vMj9Wj"

	fmt.Printf("%s\n", ss)
	enss := url.QueryEscape(ss)
	//eenss := url.QueryEscape(enss)
	fmt.Printf("query escape: \n%s\n", enss)
	//fmt.Printf("query escape escape: \n%s\n", eenss)
	unss, _ := url.QueryUnescape(ss)
	fmt.Printf("query unescape: \n%s\n", unss)

	sa := "Kiw6C3936zK/+9fC1L2WVNB0qjp9x+dvB7pOf2v1s9rYGsoZoeK5CIxRTJxaHIH/F82YyOyaejwwGMO1rtDc3vMj9Wj6oHZlFBzN14k9n0msCf1tBimmuA6c93olDUuZ1g5juT"
	fmt.Printf("%s\n", sa)
	unsa, _ := url.QueryUnescape(sa)
	fmt.Printf("query unescape: \n%s\n", unsa)
	ensa := url.QueryEscape(sa)
	fmt.Printf("query escape: \n%s\n", ensa)
}
