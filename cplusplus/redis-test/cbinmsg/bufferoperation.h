/****************************************************************************
* 版权所有  ： (C)2010 深圳市迅雷网络技术有限公司
* 设计部门  ： 迅雷会员帐号部门 
* 系统名称  : 迅雷会员帐号部门异步框架
* 文件名称  : bufferoperation.h
* 内容摘要  : 
* 当前版本  : 1.4
* 作    者  : 叶耿睿陈志敏
* 设计日期  : 2010年11月11日
* 修改记录  :
* 修改记录  ：
  *1）、版本号
       *日  期：
       *修改人：
       *摘  要：   
****************************************************************************/

#ifndef __BUFFEROPERATION_H_
#define __BUFFEROPERATION_H_

#include <string>

using namespace std;

unsigned long long LBER_HTONL(unsigned long long ll);
unsigned long long LBER_NTOHL(unsigned long long ll);

class CBufferManage
{       
public:
	enum
	{
		Err_Buffer_Param = -1,
		Err_Buffer_Overflow = -2,
		Err_Buffer_NoEnough = -3,
		Err_Buffer_NoData = -4
	};
	
    CBufferManage();
    ~CBufferManage();

    int  AttachBuffer(char* szBuffer, int iBufferLen);
    int  DetachBuffer();

    char* GetBuffer();
    int   GetBufferLen();
    int   GetBufferOffset();
	
    int  SetOffset(int iOffset);
        
    int GetInt(int& iValue);
    int GetLong64(unsigned long long& llValue);
    int GetChar(char& cValue);
	
    int GetString(string& strValue);        
    int GetString(char* szBuffer, int& iBufferLen);
	int GetString(char** ppBuffer, int& iBufferLen);
	
    int GetCharBuffer(char* szBuffer, int& iBufferLen);
    int GetCharBuffer(char** ppBuffer, int& iBufferLen);
		
    int PutInt(const int iValue);
    int PutLong64(const unsigned long long llValue);
    int PutChar(const char cValue);
	
    int PutString(const string& strValue);
	int PutString(const char* pStr, int& iLength);
	
    int PutCharBuffer(const char* szBuffer, int& iBufferLen);
	
private:
    char* m_szBuffer;
    int   m_iBufferLen;
    int   m_iOffset;
};


inline int CBufferManage::AttachBuffer(char* szBuffer, int iBufferLen)
{
	if (szBuffer == NULL || iBufferLen <= 0)
		return Err_Buffer_Param;
	
	m_szBuffer = szBuffer;
	m_iBufferLen = iBufferLen;
	m_iOffset = 0;
	
	return 0;
}


inline int CBufferManage::DetachBuffer()
{
	m_szBuffer = NULL;
	m_iBufferLen = 0;
	m_iOffset = 0;

	return 0;
}


inline char* CBufferManage::GetBuffer()
{
	return m_szBuffer;
}

	
inline int CBufferManage::GetBufferLen()
{
	return m_iBufferLen;
}


inline int CBufferManage::GetBufferOffset()
{
	return m_iOffset;
}


inline int CBufferManage::SetOffset(int iOffset)
{
	if (iOffset > m_iBufferLen)
		return Err_Buffer_Param;
	
	 m_iOffset = iOffset;
	 return 0;
}

#endif

