package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
	//"count.kankan.com/xprotocol"
)

func fn(fl *flag.Flag) {
	fmt.Printf("flag name: %s, value:%s", fl.Name, fl.Value.String())
}

func main() {
	mp := make(map[string]string)
	for _, v := range os.Args[1:] {
		res := strings.Split(v, ":")
		vv := ""
		if len(res) == 2 {
			vv = res[1]
		}
		mp[res[0]] = vv
	}

	for n, v := range mp {
		fmt.Printf("name:%s -> %s\n", n, v)
	}
}
