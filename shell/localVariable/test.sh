#!/bin/bash

aa="aaa"

ff()
{
	echo bbb
}

echo before function.
echo $aa
aa=$(echo bbb | while read line 
do
	ff
done)
echo after function.
echo $aa
