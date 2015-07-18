#include <string.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>
#include <utmp.h>

int main(int argc, char *argv[])
{
    char file[256] = "/home/flueg/workspace/utmp/ftmp";
    utmpname(file);
    struct utmp entry;

    memset(&entry, 0, sizeof(struct utmp));
    entry.ut_type=LOGIN_PROCESS;
    entry.ut_pid=getpid();
    strcpy(entry.ut_line,ttyname(0)+strlen("/dev/"));
    strcpy(entry.ut_id,ttyname(0)+strlen("/dev/tty"));
    strcpy(entry.ut_user,getpwuid(getuid())->pw_name);
    time(&entry.ut_time);
    gethostname(entry.ut_host, 256);

    setutent();
    if(pututline(&entry) == NULL) perror("failed to pututline.\n");

    //entry.ut_type = DEAD_PROCESS;
    setutent();
    if(pututline(&entry) == NULL) perror("failed to pututline.\n");

    endutent();
    return 0;
}
