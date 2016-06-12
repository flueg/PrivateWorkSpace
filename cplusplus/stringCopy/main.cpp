#include<stdio.h>
#include<iostream>
#include<sstream>
#include<string.h>

using namespace std;

int main()
{
	char *buf = new char[1024];
	buf[0] = 'F';
	buf[1] = 'l';
	buf[2] = 'u';
	buf[3] = 'e';
	buf[4] = 'g';
	buf[5] = '\0';
	buf[6] = 'L';
	buf[7] = 'i';
	buf[8] = 'u';
	buf[9] = ' ';
	buf[10] = '\0';
	buf[11] = 'i';
	buf[12] = 's';
	buf[13] = ' ';
	buf[14] = 'm';
	buf[15] = 'e';
	buf[16] = '.';
	buf[17] = '\0';

	//cout << "size: " << sizeof(buf) << " char: " << buf << endl;
	printf("size: [%d] char: [%s]\n", sizeof(buf), buf);
	//cout.write(buf, 20);

	stringstream sstr;
	//sstr << ">>>>>>stringstream test: ";
	sstr.write(">>>>>>\0string\0stream\0 test\0: ", 30);
	sstr.write(buf, 20);
	cout << "sstr get count: " << sstr.gcount() << endl;
	string sBuf = sstr.str();
	unsigned int slen = sBuf.size();
	cout << "string len: "<< slen << " buf: " << sBuf << endl;

	char* pBuf = new char[slen];
	// Note that strncpy cosiders the first '\0' it meet as end of string flag.
        //strncpy(pBuf, sBuf.c_str(), slen);
	//cout << "strncpy string: " << pBuf << " pBuf size: " << sizeof(pBuf) << endl;

	streambuf * ssbuf = sstr.rdbuf();
	ssbuf->sgetn(pBuf,slen);
	cout.write(pBuf, slen);

}
