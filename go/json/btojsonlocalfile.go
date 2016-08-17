package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
)

type Singer struct {
	Area       string `json:"Farea"`
	Attribute3 string `json:"Fattribute_3"`
	Attribute4 string `json:"Fattribute_4"`
	Genre      string `json:"Fgenre"`
	Index      string `json:"Findex"`
	OtherName  string `json:"Fother_name"`
	SingerId   string `json:"Fsinger_id"`
	SingerMid  string `json:"Fsinger_mid"`
	SingerName string `json:"Fsinger_name"`
	SingerTag  string `json:"Fsinger_tag"`
	Sort       string `json:"Fsort"`
	Trend      string `json:"Ftrend"`
	Type       string `json:"Ftype"`
	Voc        string `json:"voc"`
}

type SingerData struct {
	PerPage int `json:"per_page"`

	Lists     []Singer `json:"list"`
	Total     int      `json:"total"`
	TotalPage int      `json:"total_page"`
}

// json response from QQMusic
type RespData struct {
	Code    int        `json:"code"`
	Data    SingerData `json:"data"`
	Message string     `json:"message"`
	SubCode int        `json:"subcode"`
}

func main() {
	file := "data"
	body, err := ioutil.ReadFile(file)
	if err != nil {
		fmt.Printf("Failed to open file. err:%s\n", err)
	}

	fmt.Printf("file body:[%s]\n", body)

	respData := &RespData{}
	err = json.Unmarshal(body, respData)
	if err != nil {
		fmt.Printf("Error: Failed to unmarshal json. %s\n", err)
	}

	fmt.Printf("Json structure: code:%d, subcode:%d, messge:%s\n", respData.Code, respData.SubCode, respData.Message)
	fmt.Printf("Json structure: page:%d, total:%d, per:%d\n", respData.Data.Total, respData.Data.TotalPage, respData.Data.PerPage)
	//fmt.Printf("Json data length: %d/n", len(respData.Data.Lists))

	//for i := 0; i < list1.NumField(); i++ {
	//	f := list1.Field(i)
	//	fmt.Printf("%d: %s %s = %v\n", i, typeOfT.Field(i).Name, f.Type(), f.Interface())
	//}

}
