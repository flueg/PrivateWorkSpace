#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <pwd.h>
#include <unistd.h>
#include <utmp.h>
#include <time.h>

#define UT_LINESIZE 64
#define UT_NAMESIZE 256

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
   printf("         -n number of records need to add/erase\n");
   printf("         -e erase user login records mode. (default add mode)\n");
   printf("            will erase the records from the end of utmp file.\n");
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
    int ch, erase = 0;
    FILE *fd;
    int loop = 1;
    
    char file[256] = "/home/flueg/workdir/utmp/ftmp";
    struct utmp entry;

    memset(entry.ut_line, 0, UT_LINESIZE);
    memset(entry.ut_user, 0, UT_NAMESIZE);
    strcpy(device, ttyname(0)+strlen("/dev/"));
    strcpy(entry.ut_id,ttyname(0)+strlen("/dev/tty"));
    strcpy(user,getpwuid(getuid())->pw_name);
    time(&login_time);
    gethostname(host, 256);
    while ((ch = getopt(argc, argv, "n:u:f:i:t:m:dhe")) != -1)
    {
        switch(ch)
        {
            case 'n':
		loop = atoi(optarg);
		break;
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
		break;
	    case 'e':
		erase = 1;
            default:
                break;
        }
    }
    while (loop--)
    {
	if(erase)
	{
	    fd = fopen(file, "a+");
	    if (fd == NULL) {fputs("open file failed.", stderr); exit (1);}
	    fseek(fd, 0, SEEK_END);
	    ftruncate(fileno(fd), ftell(fd) - 2 * sizeof(entry));
  	}
	else
	{	
	    fd = fopen(file, "a");
	    if (fd == NULL) {fputs("open file failed.", stderr); exit (1);}
	    entry.ut_type=USER_PROCESS;
	    entry.ut_pid=getpid();
	    strcpy(entry.ut_line, device);
	    strcpy(entry.ut_id, ttyname(0)+strlen("/dev/tty"));
	    strcpy(entry.ut_user, user);
	    entry.ut_time = login_time;
	    strcpy(entry.ut_host, host);
	    fwrite(&entry, sizeof(entry), 1, fd);
	    //if(pututline(&entry) == NULL) perror("failed to pututline.\n");

	    struct utmp entry_dead;
	    memset(entry_dead.ut_line, 0, UT_LINESIZE);
	    memset(entry_dead.ut_user, 0, UT_NAMESIZE);
	    entry_dead.ut_time = login_time;
	    strcpy(entry_dead.ut_id,ttyname(0)+strlen("/dev/tty"));
	    entry_dead.ut_type = DEAD_PROCESS;
	    fwrite(&entry_dead, sizeof(entry_dead), 1, fd);
	    //if(pututline(&entry_dead) == NULL) perror("failed to pututline.\n");
	}
    }

    fclose(fd);
    return 0;
}
