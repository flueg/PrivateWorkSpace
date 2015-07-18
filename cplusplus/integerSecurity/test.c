#include <stdio.h>

// Integer types length
//#define A

#define B

//#define C

//#define D

#ifdef A
void func_a()
{
    printf("Check the length of integer types...\n");
    printf("==============================================\n");
    unsigned char uc;
    unsigned short int usi;
    unsigned int ui;
    unsigned long int uli;
    unsigned long long int ulli;

    signed char c, cm;
    short int si, sim;
    int i, im;
    long int li, lim;
    long long int lli, llim;

    /*unsigned integer types*/
    uc = -1;
    printf("Bytes of unsigned char: %u\n", sizeof(uc));
    printf("Range: [%u,%u]\n\n", 0, uc);

    usi = -1;
    printf("Bytes of unsigned short integer: %u\n", sizeof(usi));
    printf("Range: [%u,%u]\n\n", 0, usi);

    ui = -1;
    printf("Bytes of unsigned integer: %u\n", sizeof(ui));
    printf("Range: [%u,%u]\n\n", 0, ui);

    uli = -1;
    printf("Bytes of unsigned long integer: %u\n", sizeof(uli));
    printf("Range: [%u,%lu]\n\n", 0, uli);

    ulli = -1;
    printf("Bytes of unsigned long long integer: %u\n", sizeof(ulli));
    printf("Range: [%u,%llu]\n\n", 0, ulli);

    /*signed integer types*/
    printf("------------------\n");
    c = 0x80;
    cm = 0x7F;
    printf("Bytes of signed char: %d\n", sizeof(c));
    printf("Range: [%hhd,%hhd]\n\n", c, cm);

    si = 0x8000;
    sim = 0x7fff;
    printf("Bytes of signed short integer: %d\n", sizeof(si));
    printf("Range: [%hd,%hd]\n\n", si, sim);

    i = 0x80000000;
    im = 0x7fffffff;
    printf("Bytes of signed integer: %d\n", sizeof(i));
    printf("Range: [%d,%d]\n\n", i, im);

    li = 0x8000000000000000;
    lim = 0x7fffffffffffffff;
    printf("Bytes of signed long integer: %d\n", sizeof(li));
    printf("Range: [%ld,%ld]\n\n", li, lim);

    lli = 0x8000000000000000;
    llim = 0x7fffffffffffffff;
    printf("Bytes of unsigned long long integer: %d\n", sizeof(lli));
    printf("Range: [%lld,%lld]\n\n", lli, llim);

    printf("---------------------\n");
    printf("Bytes of size_t: %d\n", sizeof(size_t));
}
#endif

#ifdef B
void func_b()
{
    printf("Integer conversions...\n");
    printf("==============================================\n");
    unsigned short int st = 0x8E0A;
    short int convert_st = st;
    int convert_t = st; 
    unsigned char convert_ct = st;
    printf("unsigned short int: [%u],\nAfter converted to signed int: [%d]\n", st, convert_t);
    //loss of sign (sign errors)
    printf("\nloss of sign:\n");
    printf("unsigned short int: [%u],\nAfter converted to signed short int: [%hd]\n", st, convert_st);
    //loss of data (truncation)
    printf("\nloss of data(truncation):\n");
    printf("unsigned short int: [%u],\nAfter converted to unsigned char: [%hhd]\n", st, convert_ct);

    //wrap around
    st = 0xFFFF;
    printf("\nWraparound:\n");
    printf("maxinum of unsigned short int: [%u],\n", st);
    printf("%u plus 1 equal to: ", st);
    st += 1;
    printf("[%u]\n", st);

    signed char sc = 127;
    printf("maxinum of char: [%d],\n", sc);
    printf("%d plus 1 equal to: ", sc);
    sc += 1;
    printf("[%d]\n", sc);
}
#endif

#ifdef C
void func_c()
{
    unsigned char i = 5;
    for (; i >= 0; i--)
    {
        printf("%u\n", i);
    }
}
#endif

#ifdef D
void func_d()
{
    printf("d\n");
}
#endif

int main()
{
#ifdef A
    func_a();
#endif
#ifdef B
    func_b();
#endif
#ifdef C
    func_c();
#endif
#ifdef D
    func_d();
#endif
}
