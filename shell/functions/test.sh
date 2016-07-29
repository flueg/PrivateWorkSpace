#!/bin/bash

fun()
{
	if [ $1 = "true" ]; then
		return 0
	else
		return 1
	fi
}

fun true
echo $?
fun "aaa"
echo $?

