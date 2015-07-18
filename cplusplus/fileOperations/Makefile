flueg geulf: writeout.o checkstr.o
		g++ -Wall -g writeout.o -o flueg
		g++ -Wall -g checkstr.o -o geulf

writeout.o: writeout.cpp
	g++ -Wall -g -c writeout.cpp

checkstr.o: checkstr.cpp
	g++ -Wall -g -c checkstr.cpp

clean:
	rm *.o flueg geulf
