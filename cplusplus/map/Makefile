CC=g++
CCLDD_FLAGS = -lstdc++
##CCFLAGS = -std=c++11

a: test.o
	$(CC) $(CCLDD_FLAGS) test.o -o a

test.o: test.cpp
	$(CC) $(CCFLAGS) -c test.cpp

clean:
	rm a test.o

