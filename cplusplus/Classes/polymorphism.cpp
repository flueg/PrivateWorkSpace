/*
 * We can implictly upcast the derived class pointer to its base class.
 * Note that While we try to release memory of a upcasted pointer directly, we might leak the memory occupied by derived class the upcasted.
 *
 */

#include <iostream>
using namespace std;

class Base {
public:
    virtual void init() {
        cout << "This the base class." << endl;
    }
    Base() {
        cout << "Consturct class Base." << endl;
    }
    ~Base() {
        cout << "Deconsturct class Base." << endl;
    }
};

class DerivedFirst: public Base {
    int *foo;
public:
    DerivedFirst() {
        foo = new int [10];
        cout << "Construct an default int array for 10 capability." << endl;
    }
    DerivedFirst(int n) {
        foo = new int [n];
        cout << "Construct an int array for " << n << " capability." << endl;
    }
    ~DerivedFirst() {
        delete[] foo;
        cout << "Deconstruct derived first class." << endl; 
    }

    void init() {
        cout << "This is the derived fisrst." << endl;
    }
};

class DerivedSecond: public Base {
public:
    void init() {
        cout << "This is the derived second." << endl;
    }
};

int main()
{
    Base *p1, *p2, *p3;
    p1 = new DerivedFirst;
    p1->init();
    delete p1; // Such operation will lead pointer to leak memory for derived class.
    
    p2 = new DerivedSecond;
    p2->init();
    delete p2; // Such operation will lead pointer to leak memory for derived class.

    p3 = new DerivedFirst(5);
    p3->init();
    delete dynamic_cast<DerivedFirst*>(p3); // We should delete the downcast pointer. Since the pointer was upcast after declared.
    return 0;
}
