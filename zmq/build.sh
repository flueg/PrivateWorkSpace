#!/bin/bash

CWD=$(cd `dirname $0`; pwd)
export GOPATH=$GOPATH:$CWD

go install helloword/server
go install helloword/client
