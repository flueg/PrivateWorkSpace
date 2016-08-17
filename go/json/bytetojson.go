package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
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
	Lists     []Singer `json:"list"`
	PerPage   int      `json:"per_page"`
	Total     int      `json:"total"`
	TotalPage int      `json:"total_page"`
}

// json response from QQMusic
type RespData struct {
	Code    int        `json:"code"`
	SubCode int        `json:"subcode"`
	Message string     `json:"message"`
	MData   SingerData `json:"data"`
}

func main() {
	URL := "http://i.y.qq.com/v8/fcg-bin/v8.fcg?channel=singer&page=list&key=cn_man_all&pagesize=100&pagenum=1&loginUin=429489604&hostUin=0&format=json&inCharset=GB2312&outCharset=&notice=0&platform=jqspaframe.json&needNewCode=0"
	resp, err := http.Get(URL)
	if err != nil {
		fmt.Printf("Failed to process http request. err:%s\n", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		fmt.Printf("Http request error: %d\n", resp.StatusCode)
	}

	var header string
	for k, v := range resp.Header {
		tmp := k + " -> " + strings.Join(v, ",")
		header = header + "[" + tmp + "]"
	}
	fmt.Printf("http response header:%s\n", header)

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Failed to read http response data. err:%s\n", err)
	}
	fmt.Printf("http response body:[%s]\n", body)

	respData := &RespData{}
	err = json.Unmarshal(body, respData)
	if err != nil {
		fmt.Printf("Error: Failed to unmarshal json. %s\n", err)
	}

	fmt.Printf("Json structure: code:%d, subcode:%d, messge:%s\n", respData.Code, respData.SubCode, respData.Message)
	fmt.Printf("Json structure: total:%d, total_page:%d, per_page:%d\n", respData.MData.Total, respData.MData.TotalPage, respData.MData.PerPage)
	fmt.Printf("Json data length: %d/n", len(respData.MData.Lists))

	//for i := 0; i < list1.NumField(); i++ {
	//	f := list1.Field(i)
	//	fmt.Printf("%d: %s %s = %v\n", i, typeOfT.Field(i).Name, f.Type(), f.Interface())
	//}

}
