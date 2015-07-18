#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <pwd.h>
#include <unistd.h>
#include <utmp.h>
#include <time.h>

//char file[256] = "/home/flueg/workspace/build/utmp/ftmp";
char file[256] = "wtmp.fake";
time_t login_time;
char device[32];
char user[32];
char host[256];
char debug = 0;
struct tm cur_tm;

void Usage()
{
   printf("Usage of fake utmp:\n"); 
   printf("utmp [options]\n");
   printf("\n");
   printf("Option:  -f filename, default output file: ./wtmp.fake\n");
   printf("         -u user name, default current user\n");
   printf("         -i ip address or host, default current host\n");
   printf("         -t fake login begin time, default current time\n");
   printf("            time format: year/mon/mday-hour:min:sec\n");
   printf("         -m login method or login device, default current console\n");
   printf("         -d enable debug messge\n");
   printf("\n");
   printf("         -h help\n");
}

void DEBUG_OUT(char *msg)
{
   if(debug) printf(msg); 
}

time_t gettime(char *t)
{
    int year, mon, day, hour=0, min=0, sec=0;
    sscanf(t, "%d/%d/%d-%d:%d:%d", &year, &mon, &day, &hour, &min, &sec);
    
    cur_tm.tm_year = year - 1900;
    cur_tm.tm_mon = mon - 1;
    cur_tm.tm_mday = day;
    cur_tm.tm_hour = hour;
    cur_tm.tm_min = min;
    cur_tm.tm_sec = sec;
    cur_tm.tm_isdst = -1;

    return  mktime(&cur_tm);
}

int main(int argc, char *argv[])
{
    int ch;
    int i;
    FILE *fd;
    char msg[256];
    struct exit_status xstat;
    time(&login_time);
    strcpy(device, ttyname(0) + strlen("/dev/"));
    struct utmp entry;

    printf("size of struct utmp: %d\n", sizeof(entry));

    printf("size of struct utmp.ut_type: %d\n", sizeof(entry.ut_type));
    printf("size of struct utmp.pid: %d\n", sizeof(entry.ut_pid));
    printf("size of struct utmp.ut_line: %d\n", sizeof(entry.ut_line));
    printf("size of struct utmp.ut_id: %d\n", sizeof(entry.ut_id));
    printf("size of struct utmp.ut_user: %d\n", sizeof(entry.ut_user));
    printf("size of struct utmp.ut_host: %d\n", sizeof(entry.ut_host));
    printf("size of struct utmp.ut_exit: %d\n", sizeof(entry.ut_exit));
    printf("size of struct utmp.ut_session: %d\n", sizeof(entry.ut_session));
    printf("size of struct utmp.ut_tv: %d\n", sizeof(entry.ut_tv));
    printf("size of struct utmp.ut_addr_v6: %d\n", sizeof(entry.ut_addr_v6));
    printf("size of struct utmp.__unused: %d\n", sizeof(entry.__unused));

    memset(&entry, 0, sizeof(struct utmp));
    // Set the login user as default user name.
    strcpy(user,getpwuid(getuid())->pw_name);
    // Set the local hostname as default default.
    gethostname(host, sizeof(char) * 256);

    while ((ch = getopt(argc, argv, "u:f:i:t:m:dh")) != -1)
    {
        switch(ch)
        {
            case 'u':
                sprintf(user, "%s", optarg);
                break;
            case 'f':
                strcpy(file, optarg);
                break;
            case 'i':
                sprintf(host, "%s", optarg);
                break;
            case 't':
                login_time = gettime(optarg);
                break;
            case 'm':
                sprintf(device, "%s", optarg);
                break;
            case 'h':
                Usage();
                break;
            case 'd':
                // enable debug message.
                debug = 1;
            default:
                break;
        }
    }
    sprintf(msg, "echo before adding entry:;last -f %s", file);

    fd = fopen(file, "a");
    

    entry.ut_type=USER_PROCESS;
    entry.ut_pid=getpid();
    sprintf(msg, "set login console: %s\n", device);
    DEBUG_OUT(msg);
    strcpy(entry.ut_line, device);
    sprintf(msg, "set login user: %s\n", user);
    DEBUG_OUT(msg);
    strcpy(entry.ut_user, user);
    sprintf(msg, "set login host: %s\n", host);
    DEBUG_OUT(msg);
    strcpy(entry.ut_host, host);
    /* only correct for ptys named /dev/tty[pqr][0-9a-z] */
    strcpy(entry.ut_id,ttyname(0)+strlen("/dev/tty"));
    sprintf(msg, "set user login time: %d\n", login_time);
    DEBUG_OUT(msg);
    entry.ut_time = login_time;

    xstat.e_termination = EXIT_SUCCESS;
    xstat.e_exit = DEAD_PROCESS; 
    entry.ut_exit = xstat;
    
    fwrite(&entry, sizeof(entry), 1, fd);

    fclose(fd); 
    sprintf(msg, "echo After adding user login entries:; last -f %s", file);
    return 0;
}
