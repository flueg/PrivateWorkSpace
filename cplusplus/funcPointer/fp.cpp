/**
 * Demo of Function Pointer
 * Function pointer can provide us a convenient way to call different functions
 * with the same return type
 *
 * flueg.liu@gmail.com
 **/
#include <stdio.h>
#include <string>

typedef std::string (*PropsGetDV)();
typedef int (*PropsGetInt)();

std::string func()
{
    printf("Hello string Function 1!\n");
    return "yes";
}

std::string func2()
{
    printf("Hello string Function 2!\n");
    return "yes";
}

int func3()
{
    printf("Hello int Function 3!\n");
    return 1;
}

void boo(PropsGetDV f)
{
    (*f)();
}

void boo(PropsGetInt f)
{
    (*f)();
}

int main()
{
    // we can use typedef to declare the function pointer type
    PropsGetDV ss[] = {&func, &func2};
    PropsGetInt sa = &func3;
    for(int i = 0; i < 2; i++)
        boo(ss[i]);
    boo(sa);

    // we can also declare the function pointer directly 
    std::string (*s3)() = &func;
    s3();

    boo(&func2);
}
