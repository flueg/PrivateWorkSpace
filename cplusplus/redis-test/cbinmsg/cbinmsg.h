/****************************************************************************
* 版权所有  ： (C)2010 深圳市迅雷网络技术有限公司
* 设计部门  ： 迅雷会员帐号部门 
* 系统名称  : 迅雷会员帐号部门异步框架
* 文件名称  : cbinmsg.h
* 内容摘要  : 
* 当前版本  : 1.4
* 作    者  : 叶耿睿，陈志敏
* 设计日期  : 2010年11月11日
* 修改记录  :
* 修改记录  ：
  *1）、版本号
       *日  期：
       *修改人：
       *摘  要：   
****************************************************************************/

#ifndef _CBINMSG_H_
#define _CBINMSG_H_

#include <string>
#include <vector>

/*
#ifdef __x86_64
#define FORMAT_UINT_64 "lu"
#define FORMAT_INT_64 "ld"
#else
#define FORMAT_UINT_64 "llu"
#define FORMAT_INT_64 "lld"
#endif
*/
//使用标准int类型定义: 
#ifndef __STDC_FORMAT_MACROS
#define __STDC_FORMAT_MACROS
#endif
#include <inttypes.h>

using namespace std;

enum ErrBinMsg
{
	Err_BinMsg_FieldDecode = -1,
	Err_BinMsg_RowDecode = -2,
	Err_BinMsg_RecDecode = -3,

	Err_BinMsg_FieldEncode = -4,
	Err_BinMsg_RowEncode = -5,
	Err_BinMsg_RecEncode = -6,	

	Err_BinMsg_Param = -7,
	Err_BinMsg_NoEnough = -8
};


class CBinMsgField
{
public:
	CBinMsgField();
	~CBinMsgField();

	void GetSize(int& iFieldSize);
		
	int Encode(char* szBuffer, int& iBufferLen);
	int Decode(const char* szBuffer, int iBufferLen);

	std::string	m_strName;
	std::string m_strValue;
};


class CBinMsgRow
{
public:
	CBinMsgRow();
	CBinMsgRow(const std::string &strInMsg);
	~CBinMsgRow();

	void GetSize(int& iRowSize);
	
	int  Encode(char* szBuffer, int& iBufferLen);
	int  Decode(const char* szBuffer, int iBufferLen);

	int GetFieldNum();
	
	CBinMsgField*  GetNextField();
	CBinMsgField*  GetField(int iIdx);
	std::string  GetField(const std::string &strName);
	
	void AddField(CBinMsgField clsField);	
	void AddField(const std::string &strName, const std::string &strValue);
	void AddField(const std::string &strName, char cValue);
	void AddField(const std::string &strName, int32_t iValue);
	void AddField(const std::string &strName, uint32_t ulValue);
	void AddField(const std::string &strName, int64_t llValue);
	void AddField(const std::string &strName, uint64_t ullValue);

	void SetField(const std::string &strName, const std::string &strValue);
	void SetField(const std::string &strName, char cValue);
	void SetField(const std::string &strName, int32_t iValue);
	void SetField(const std::string &strName, uint32_t ulValue);
	void SetField(const std::string &strName, int64_t llValue);
	void SetField(const std::string &strName, uint64_t ullValue);

	int FindField(const std::string &strName);

private:
	vector<CBinMsgField> m_vecField;
	
	int m_iFieldNum;
	int m_iReadField;
};


class CBinMsgRecord
{
public:
	CBinMsgRecord();
	~CBinMsgRecord();

	void GetSize(int& iRecSize);
	
	int Encode(char* szBuffer, int& iBufferLen);
	int Decode(const char* szBuffer, int iBufferLen);

	int GetRowNum();
	CBinMsgRow* GetNextRow();
	CBinMsgRow* GetRow(int iIdx);
	
	void AddRow(CBinMsgRow objMsgRow);
	
private:
	vector<CBinMsgRow> m_vecRow;
	int m_iRowNum;
	int m_iReadRow;
};
#endif

