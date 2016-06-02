package main

import (
	"time"
)

func main() {
	timeout := make(chan bool, 1)
	ch := make(chan int, 1)
	go func() {
		time.Sleep(1e9) // 等待1秒钟
		timeout <- true
	}()
	// 然后我们把timeout这个channel利用起来
	select {
	case <-ch: // 从ch中读取到数据
	case <-timeout: // 一直没有从ch中读取到数据，但从timeout中读取到了数据
	}
}
