package main

import (
	"crypto/md5"
	"crypto/sha1"
	"fmt"
)

func main() {
	var TestString string
	for {
		fmt.Scanln(&TestString)

		Result1 := md5.Sum([]byte(TestString))
		fmt.Printf("md5 1: %x\n", Result1)
		tmpMd5 := fmt.Sprintf("%x", Result1)
		Result := md5.Sum([]byte(tmpMd5))
		tmpMd52 := fmt.Sprintf("%x", Result)
		fmt.Printf("md5 2: %s\n", tmpMd52)
		// Second md5 value
		//Md5Inst1 := md5.New()
		//Md5Inst1.Write([]byte(tmpMd5))
		//Result = Md5Inst1.Sum([]byte(""))
		//fmt.Printf("md5 2: %x\n", Result)

		// Third: sha1 value
		//Sha1Inst := sha1.New()
		//Sha1Inst.Write([]byte(tmpMd52))
		//Result2 := Sha1Inst.Sum([]byte(""))
		Result2 := sha1.Sum([]byte(tmpMd52))
		fmt.Printf("sha1 after md5 2: %x\n", Result2)
	}
}
