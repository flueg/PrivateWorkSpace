package main

import (
	"fmt"
)

func main() {
	row := make(map[string]interface{}, 1)
	var sid int = 3
	var sname string = "fluegliu"
	row["sid"] = sid
	row["sname"] = sname
	fmt.Printf("other type to interface\n\tsid: %v, sname:%v\n", row["sid"], row["sname"])

	ikeyid := row["sid"]
	ikeyname := row["sname"]
	keyid := (ikeyid).(int)
	keyname := (ikeyname).(string)
	fmt.Printf("interface type to other\n\tsid: %d, sname:%s\n", keyid, keyname)
}
