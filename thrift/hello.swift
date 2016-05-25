namespace go Hello

const string VERSION = "19.24.0"

service HelloWord {
	void Ping(),
	i32 SayHello(string str)
}
