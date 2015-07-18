#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
    setuid(0);
    system("whoami");
    system("bash -c /bin/true");
    return 0;
}
