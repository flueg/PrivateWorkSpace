#include <iostream>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

using namespace std;

void openFile(char * file)
{
    FILE *fd = fopen(file, "r");
    if (fd == NULL)
    {
        cout << "ERROR: cannot open file: "<< file <<" [" << strerror(errno) <<"]" << endl;
        return;
    }
    else
    {
        cout << "Open file: "<< file <<" Succeed." << endl;
        fclose(fd);
    }
}

void showUids()
{
    uid_t ruid[20], euid[20], suid[20];
    if (getresuid(ruid, euid, suid))
    {
        cout << "Failed to get the the xuid: " << strerror(errno) << endl;
        return;
    }
    cout << "current user uid is: [" << *ruid << "], " \
         << "euid is [" << *euid << "], " \
         << "suid is [" << *suid << "], " \
         << endl;

}
int main()
{
    uid_t ruid;
    char file[] = "/etc/shadow";
    showUids();
    openFile(file);
    cout << endl;

    ruid = getuid();
    if (seteuid(ruid))
    {
        cout << "Failed to set the the euid: " << strerror(errno) << endl;
    }
    else
    {
        cout << "2: change the euid to ["<< ruid <<"]." << endl;
        showUids();
        openFile(file);
    }
    cout << endl;
    

    ruid = 0;
    if (seteuid(ruid))
    {
        cout << "Failed to set the the euid: " << strerror(errno) << endl;
    }
    else
    {
        cout << "3: change the euid to ["<< geteuid()<<"]." << endl;
        showUids();
        openFile(file);
    }
    cout << endl;

    // Drop the root privilege forever.
    ruid = getuid();
    if (setuid(ruid))
    {
        cout << "Failed to set the the euid: " << strerror(errno) << endl;
        return errno;
    }
    else
    {
        cout << "4: change the euid to ["<< geteuid()<<"]." << endl;
        showUids();
        openFile(file);
    }
    return 0;
}
