/****************************************************************************
* 版权所有  ： (C)2010 深圳市迅雷网络技术有限公司
* 设计部门  ： 迅雷会员帐号部门 
* 系统名称  : 迅雷会员帐号部门异步框架
* 文件名称  : bufferoperation.cpp
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


#include <netinet/in.h>
#include <stdio.h>
#include <iostream>
#include <cstring>
#include "bufferoperation.h"


unsigned long long LBER_HTONL(unsigned long long ll)
{
    unsigned long long a, b;
    sscanf("0x00000000FFFFFFFF", "%llx", &a);
    sscanf("0xFFFFFFFF00000000", "%llx", &b);
    return (((unsigned long long)htonl((ll) & a)) << 32 | htonl(((ll) & b) >> 32));
}


unsigned long long LBER_NTOHL(unsigned long long ll)
{
     unsigned long long a, b;
     sscanf("0x00000000FFFFFFFF", "%llx", &a);
     sscanf("0xFFFFFFFF00000000", "%llx", &b);
     return (((unsigned long long)ntohl((ll) & a)) << 32 | ntohl(((ll) & b) >> 32));
}


CBufferManage::CBufferManage()
{
	m_szBuffer = NULL;
	m_iBufferLen = 0;
	m_iOffset = 0;
}


CBufferManage::~CBufferManage()
{
}


/******************************************************************************
						get   buffer   operation
******************************************************************************/

int CBufferManage::GetInt(int& iValue)
{
    if (m_iOffset + (int)sizeof(int) > m_iBufferLen)
		return Err_Buffer_Overflow;

    iValue = ntohl(*(int*)(m_szBuffer + m_iOffset));
    m_iOffset += sizeof(int);
	
    return 0;
}

int CBufferManage::GetLong64(unsigned long long& llValue)
{  
    if (m_iOffset + (int)sizeof(unsigned long long) > m_iBufferLen)
		return Err_Buffer_Overflow;

    llValue = LBER_NTOHL(*(unsigned long long*)(m_szBuffer + m_iOffset));
    m_iOffset += sizeof(unsigned long long);
	
    return 0;
}


int CBufferManage::GetChar(char& cValue)
{
    if (m_iOffset + (int)sizeof(char) > m_iBufferLen)
		return Err_Buffer_Overflow;

	cValue = *(char*)(m_szBuffer + m_iOffset);
    m_iOffset += sizeof(char);  
	
    return 0;
}


int CBufferManage::GetString(string& strValue)
{
	if (m_iOffset + (int)sizeof(int) > m_iBufferLen)
	    return Err_Buffer_Overflow;

    int iLength = ntohl(*(int*)(m_szBuffer + m_iOffset));
    m_iOffset += sizeof(int);
 
	if ((m_iOffset + iLength > m_iBufferLen) || (iLength < 0))
	    return Err_Buffer_Overflow;

	strValue = string(m_szBuffer + m_iOffset, iLength);
	m_iOffset += iLength;
	
	return 0;
}


int CBufferManage::GetString(char* szBuffer, int& iLength)
{
	if (szBuffer == NULL || iLength <= 0)
		return Err_Buffer_Param;

	if (m_iOffset + (int)sizeof(int) > m_iBufferLen)
	    return Err_Buffer_Overflow;

    int iStringLen = ntohl(*(int*)(m_szBuffer + m_iOffset));	
	if (iStringLen >= iLength)
	{
		iLength = iStringLen + 1;
		return Err_Buffer_NoEnough;
	}

    if ((m_iOffset + iStringLen > m_iBufferLen) || (iStringLen < 0))
    {
    	iLength = 0;
		return Err_Buffer_Overflow;
    }
	
    m_iOffset += sizeof(int);
	
	memcpy(szBuffer, m_szBuffer + m_iOffset, iStringLen);
	szBuffer[iStringLen] = 0;
	
    m_iOffset += iStringLen;
	
    return 0;
}


int CBufferManage::GetString(char** pBuffer, int& iLength)
{
	if (pBuffer == NULL)
		return Err_Buffer_Param;
	//cout << "buffer manage GetString." << endl;

	if (m_iOffset + (int)sizeof(int) > m_iBufferLen)
	    return Err_Buffer_Overflow;
	//cout << "bufferLen:" << m_iBufferLen << " offset:" << m_iOffset << endl;

    iLength = ntohl(*(int*)(m_szBuffer + m_iOffset));

    if ((m_iOffset + iLength + (int)sizeof(int) > m_iBufferLen) || (iLength < 0))
    {
	//cout << "offset:" << m_iOffset << " iLen:" << iLength << " bufferLen:" << m_iBufferLen << endl;
    	iLength = 0;
	cerr << "buffer over flow" << endl;
		return Err_Buffer_Overflow;
    }
	
    m_iOffset += sizeof(int);
	
	*pBuffer = m_szBuffer + m_iOffset;	
    m_iOffset += iLength;
	
    return 0;
}


int CBufferManage::GetCharBuffer(char* szBuffer, int& iLength)
{
	if (szBuffer == NULL || iLength <= 0)
		return Err_Buffer_Param;

    if (m_iOffset + iLength > m_iBufferLen)
    {
    	iLength = m_iBufferLen - m_iOffset;
        return Err_Buffer_NoData;
    }
		
	memcpy(szBuffer, m_szBuffer + m_iOffset, iLength);
    m_iOffset += iLength;
	
    return 0;
}


int CBufferManage::GetCharBuffer(char** ppBuffer, int& iBufferLen)
{
	if (ppBuffer == NULL)
		return Err_Buffer_Param;

    if (m_iOffset + iBufferLen > m_iBufferLen)
    {
    	iBufferLen = m_iBufferLen - m_iOffset;
        return Err_Buffer_NoData;
    }
		
	*ppBuffer = m_szBuffer + m_iOffset;
    m_iOffset += iBufferLen;
	
    return 0;	
}


/******************************************************************************
						set   buffer   operation
******************************************************************************/

int CBufferManage::PutInt(const int iValue)
{
    if (m_iOffset + (int)sizeof(int) > m_iBufferLen)
		return Err_Buffer_NoEnough;

	*(int*)(m_szBuffer + m_iOffset) = htonl(iValue);
    m_iOffset += sizeof(int);

    return 0;
}



int CBufferManage::PutLong64(const unsigned long long llValue)
{
    if (m_iOffset + (int)sizeof(unsigned long long) > m_iBufferLen)
		return Err_Buffer_NoEnough;

	*(unsigned long long*)(m_szBuffer + m_iOffset) = LBER_HTONL(llValue);
    m_iOffset += sizeof(unsigned long long);
	
    return 0;
}


int CBufferManage::PutChar(const char cChar)
{
    if (m_iOffset + (int)sizeof(char) > m_iBufferLen)
		return Err_Buffer_NoEnough;

	*(m_szBuffer + m_iOffset) = cChar;
    m_iOffset += sizeof(char);  
	
    return 0;
}


int CBufferManage::PutString(const string& strValue)
{
    if (m_iOffset + (int)strValue.length() + (int)sizeof(int) > m_iBufferLen)
        return Err_Buffer_NoEnough;

	*(int*)(m_szBuffer + m_iOffset) = htonl(strValue.length());
    m_iOffset += sizeof(int);

	if (strValue.length() > 0)
	{
		memcpy(m_szBuffer + m_iOffset, strValue.c_str(), strValue.length());
		m_iOffset += strValue.length();
	}

    return 0;
}


int CBufferManage::PutString(const char* szBuffer, int& iLength)
{
	if (szBuffer == NULL || iLength < 0)
		return Err_Buffer_Param;

    if (m_iOffset + (int)sizeof(int) + iLength > m_iBufferLen)
    {
    	iLength = m_iOffset + sizeof(int) + iLength;
		return Err_Buffer_NoEnough;
    }
	
	*(int*)(m_szBuffer + m_iOffset) = htonl(iLength);
    m_iOffset += (int)sizeof(int);
    
    if (iLength > 0)
    {
        memcpy(m_szBuffer + m_iOffset, szBuffer, iLength);
        m_iOffset += iLength;
    }
	
    return 0;
}

int CBufferManage::PutCharBuffer(const char* szBuffer, int& iLength)
{
	if (szBuffer == NULL || iLength < 0)
		return Err_Buffer_Param;

    if (m_iOffset + iLength > m_iBufferLen)
    {
    	iLength = m_iOffset + iLength;
        return Err_Buffer_NoEnough;
    }
		
	memcpy(m_szBuffer + m_iOffset, szBuffer, iLength);
    m_iOffset += iLength;
	
    return 0;
}

