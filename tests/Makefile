testNSFunc: testClassNPFunc.cpp classNameSpaceFunc.o
	g++ testClassNPFunc.cpp classNameSpaceFunc.o -o testNSFunc

classNameSpaceFunc.o: classNameSpaceFunc.cpp 
	g++ -c classNameSpaceFunc.cpp -o classNameSpaceFunc.o  

all: testNSFunc
clean:
	$(RM) *.o testNSFunc


