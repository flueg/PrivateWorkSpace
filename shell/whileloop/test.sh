#!/bin/bash

let i=1
#while [ $i -lt 5 ]
while [ ] 
do
    echo $i ...
    ((i = $i + 10))
    #sleep 1
done

if [ 0 ] #zero
then
echo "0 is true."
else
echo "0 is false."
fi

if [ ]  #NULL (empty condition)
then
echo "NULL is true."
else
echo "NULL is false."
fi

if [ "xyz" ] #string
then
 echo "Random string is true."
else
echo "Random string is false."
fi

if [ $xyz ]  # uninitialized variable
then
echo "Uninitialized variable is true."
else
echo "Uninitialized variable is false."
fi

exit 0
