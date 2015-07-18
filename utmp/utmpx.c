#include <utmpx.h>	
#include <pwd.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    struct utmpx u;
    const char file[256] = "/home/flueg/workspace/utmp/ftmpx";
    memset(&u, 0, sizeof(struct utmpx));

    if (utmpxname(file) == -1) perror("failed to set ftmpx file");
    strcpy(u.ut_user, getpwuid(getuid())->pw_name);
    printf("ttyname is: %s\n", ttyname(0)+strlen("/dev/"));
    strcpy(u.ut_id, ttyname(0) + strlen("/dev/tty"));
    strcpy(u.ut_line, ttyname(0) + strlen("/dev/"));
    u.ut_pid = getpid();
    u.ut_type = LOGIN_PROCESS;

    setutxent();
    if (pututxline(&u) == NULL) perror("failed to pututxline.\n");

    sleep(2);
    u.ut_type = DEAD_PROCESS;
    time((time_t *) &u.ut_tv.tv_sec);
    setutxent();
    if (pututxline(&u) == NULL) perror("failed to pututxline.\n");

    endutxent();
    exit(0);
}
