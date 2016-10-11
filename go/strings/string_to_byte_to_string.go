package main

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"strconv"
	"time"
)

func GenerateSign2(key string) string {
	timestamp := time.Now().Unix()
	fmt.Printf("timestamp:  %d\n", timestamp)
	finalKey := []byte(key + ":")
	finalKey = strconv.AppendInt(finalKey, timestamp, 10)
	fmt.Printf("Final key: %s\n", string(finalKey))

	signCtx := md5.New()
	signCtx.Write(finalKey)
	sign := signCtx.Sum(nil)
	fmt.Printf("Hexmode: %x\n", sign)
	return hex.EncodeToString(sign[:16])
	//return string(sign[:16])
}

func GenerateSign(key string) string {
	timestamp := time.Now().Unix()
	fmt.Printf("timestamp:  %d\n", timestamp)
	finalKey := []byte(key + ":")
	finalKey = strconv.AppendInt(finalKey, timestamp, 10)
	fmt.Printf("Final key: %s\n", string(finalKey))

	sign := md5.Sum(finalKey)
	fmt.Printf("Hexmode: %x\n", sign)
	return hex.EncodeToString(sign[:16])
	//return string(sign[:16])
}

func main() {
	ss := "fluegliu"
	fmt.Printf("Origin key: %s\n", ss)
	ff := GenerateSign(ss)
	fmt.Printf("Sign: %s\n", ff)
	ff = GenerateSign2("fluegliu")
	fmt.Printf("Sign2: %s\n", ff)
}
