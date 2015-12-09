all: testcpp testc

testcpp: testcpp.o
	g++ testcpp.o -o testcpp 

testc: testc.o
	gcc testc.o -o testc 

testcpp.o: testcpp.cpp
	g++ -c testcpp.cpp 

testc.o: testc.c
	gcc -c testc.c 
clean: 
	rm *.o testc testcpp
