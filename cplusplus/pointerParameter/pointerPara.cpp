#include <iostream>

using namespace std;

class B;
class A
{
private:
    B &m_b;
public:
    A(B &b) : m_b(b){}
    B &getB(){return m_b;}
};

class B
{
private:
    int m_i;
public:
    B(int i) : m_i(i) {}
    void output() { cout << m_i << endl; }
    void setI(int i) { m_i = i; }
};

void init(A **a)
{
    B *b = new B(3);
    *a = new A(*b);
}

int main()
{
    A *a = 0;
    init(&a);
    a->getB().output();
    return 0;
}
