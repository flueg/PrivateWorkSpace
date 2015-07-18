#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define FLUEG_DEFAULT_STR "20"

int main ()
{
  int i;
  char strtext[] = "0";
  char cset[] = "1234567890";

  i = strspn (strtext,cset);
  printf ("The initial number lengh is %d, has %d digits.\n",strlen(strtext), i);

  unsigned int fnum = atoi(FLUEG_DEFAULT_STR);
  printf("flueg default num is [%d]\n",fnum);

  fnum = 0;
  if (i or fnum)
  {
      printf("yes\n");
  }
  else
  {
      printf("no\n");
  }
  return 0;
}
