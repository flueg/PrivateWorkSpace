flueg: setuid.o
	g++ -Wall -g setuid.o -o flueg
	sudo chown root:root flueg
	sudo chmod u+s flueg

setuid.o: setuid.cpp
	g++ -Wall -g -c setuid.cpp

clean:
	rm *.o flueg
