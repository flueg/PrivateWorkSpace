#include <iostream>
#include <string.h>
#include "cbinmsg.h"
#include "hiredis/hiredis.h"

#define GET_ARGS() 
#define DEBUG

void debug()
{
}

void putoutRecord(void* rply)
{
	redisReply* reply= (redisReply *)rply;
	if (reply == NULL || reply->len == 0) return;
	CBinMsgRecord rrec = CBinMsgRecord();
	//cout << "size of line: " << reply->len  << std::endl;
	int rc = rrec.Decode(reply->str, sizeof(char) * reply->len);
	for(int i=0;i<rrec.GetRowNum(); i++){
		CBinMsgRow * pRow=rrec.GetRow(i);
		std::cout<<"-------------------"<<endl;
		if(pRow){
			for(int j=0; j< pRow->GetFieldNum(); j++)
			{
				CBinMsgField * field=pRow->GetField(j);
				if (field == NULL) continue;
				std::cout<<field->m_strName<<" => "<<field->m_strValue<<endl;
				//delete field;
			}
		}
	}
	//std::cout<<"-------------------"<<endl;
}

void whatTheFoxSays(redisContext* conn, void *rply)
{
	redisReply *reply = (redisReply *) rply;
	if (reply->type == REDIS_REPLY_STRING)
	{
		string temp = reply->str;
		size_t pos = temp.find("FLOW_XX");
		if (pos == string::npos) return;
		cout << "get redis db list: " << reply->str << endl;
		redisReply *subreply = (redisReply *)redisCommand(conn, "LRANGE %s 0 -1", reply->str);
		if (subreply->type == REDIS_REPLY_ARRAY)
		{
			cout << "db have " << reply->elements << " entries" << endl;
			for (int j = 0; j < subreply->elements; j++)
				putoutRecord(subreply->element[j]);
		}
		freeReplyObject(subreply);	
	}
	freeReplyObject(reply);	
}

int main (int argc, char** argv)
{
	//std::cout << argv[1];
	//string host = argv[1]; 
	//if (host.size() == 0) host = "10.24.36.62");
	//int port = GET_ARGS(argv[2], 6405);
	//int db   = GET_ARGS(argv[3], 4);
	//redisContext *conn = redisConnect("10.24.36.62", 6404); // KHZ01184
	//redisContext *conn = redisConnect("10.24.36.111", 6404); // KHZ01183
	if (argc != 2) {
		cout << argv[0] << " hostIP" << endl;
		return 5;
	}
	redisContext *conn = redisConnect(argv[1], 6405); // KHZ01183
	if(conn == NULL || conn->err){
		cerr << "connection error: " << conn->errstr << endl;
		return 1;
	}
	
	//cout << "nonononononono" << endl;
	int db = 4;
	redisReply *reply = (redisReply *)redisCommand(conn, "SELECT %d", db);
	//cout << "what the fox says" << endl;
	if (reply->type != REDIS_REPLY_STATUS)
	{
		cerr << "Failed to select db:" << db << endl;
		return 2;
	}
	freeReplyObject(reply);

	reply = (redisReply *)redisCommand(conn, "KEYS *");
	//cout << "the language of love" << endl;
	if (reply->type == REDIS_REPLY_ARRAY)
	{
		cerr << "db have " << reply->elements << " list" << endl;
		for (int i = 0; i < reply->elements; i++)
		{
			whatTheFoxSays(conn, reply->element[i]);
		}
	}
	//freeReplyObject(reply);
	redisFree(conn);
	return 0;
}
