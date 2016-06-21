package main

import "fmt"

func rangeStringParas(params ...string) {
	for i, v := range params {
		fmt.Printf("%d-%s\n", i, v)
	}
}

func rangeStringParas_(params ...string) {
	result := "Append"
	for _, v := range params {
		result = result + "_" + v
	}
	fmt.Println(result)
}

func main() {
	str := "A:Go is a beautiful language!"
	str1 := "B:Haha let's do it"
	str2 := "C:Chinese: 日本語"
	str3 := "D:What's your name?"
	rangeStringParas(str, str1, str2, str3)
	rangeStringParas_(str, str1, str2, str3)
}
