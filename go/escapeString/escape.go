package main

import (
	"fmt"
)

func MysqlEscape(source string) (string, error) {
	var j int = 0
	if len(source) == 0 {
		return "", nil
	}
	tempStr := source[:]
	desc := make([]byte, len(tempStr)*2)
	for i := 0; i < len(tempStr); i++ {
		flag := false
		var escape byte
		switch tempStr[i] {
		case '\\':
			flag = true
			escape = '\\'
		case '\'':
			flag = true
			escape = '\''
		case '"':
			flag = true
			escape = '"'
		case 32:
			flag = true
			escape = 'Z'
		default:
		}
		if flag {
			desc[j] = '\\'
			desc[j+1] = escape
			j = j + 2
		} else {
			desc[j] = tempStr[i]
			j = j + 1
		}
	}
	return string(desc[0:j]), nil
}

func MysqlUnEscape(source string) (string, error) {
	var j int = 0
	if len(source) == 0 {
		return "", nil
	}
	tempStr := source[:]
	desc := make([]byte, len(tempStr))
	for i := 0; i < len(tempStr)-1; i++ {
		flag := false
		var escape byte
		if tempStr[i] == '\\' {
			flag = true
			switch tempStr[i+1] {
			case 'Z':
				escape = 32
			default:
				escape = tempStr[i+1]
			}
			i++
		}
		if flag {
			desc[j] = escape
		} else {
			desc[j] = tempStr[i]
		}
		j++
	}
	return string(desc[0:j]), nil
}

func main() {
	ss := "flueg\\ 'is' \"me."
	css, _ := MysqlEscape(ss)
	fmt.Println(css)
	rss, _ := MysqlUnEscape(css)
	fmt.Println(rss)
}
