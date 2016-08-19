package main

import (
	"fmt"
	"regexp"
	"strings"
)

func SplitName(match string) (string, string) {
	ok, err := regexp.Match(".*\\(.*\\)", []byte(match))
	if ok {
		reg, _ := regexp.Compile("([^()]+)\\s*\\((.*)\\)")
		result := reg.FindStringSubmatch(match)
		fmt.Printf("result: %s\n", strings.Join(result, ";"))
		if len(result) > 1 {
			return result[1], result[2]
		}
	} else {
		fmt.Printf("Match Error. %s\n", err)
		return match, ""
	}
	return "", ""
}
func main() {
	var aaa string = "刘洪广  (Flueg Liu)"
	pre, suf := SplitName(aaa)
	fmt.Printf("pre:%s, suf:%s\n", pre, suf)

	aaa = "刘洪广 Flueg Liu "
	pre, suf = SplitName(aaa)
	fmt.Printf("pre:%s, suf:%s\n", pre, suf)

	aaa = "刘洪广 (Flueg Liu "
	pre, suf = SplitName(aaa)
	fmt.Printf("pre:%s, suf:%s\n", pre, suf)
}
