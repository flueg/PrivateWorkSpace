#include <iostream>
#include <fstream>
#include "stdio.h"

#define CIMS_CONF "/etc/centrifydc/centrifydc.conf"

int main()
{
    std::string file = "testfile.txt";
    try
    {
        std::ofstream out(file.c_str());
        if(out.is_open())
            out << "testing 1" << std::endl;
        else
        {
            std::cout << "Cannot open file " << file << std::endl;
        }
        std::ofstream out1(file.c_str());
        if(out1.is_open())
            out1 << "testing 2" << std::endl;
        else
        {
            out.close();
            std::cout << "Cannot open file " << file << std::endl;
        }
        out1.close();
        out.close();
    }
    catch(...)
    {
        std::cout << "Catch exception" << std::endl;
    }

    printf("conf file: %s\n", CIMS_CONF);

    return 0;
}
