#!/bin/bash

printf "Creating dir /tmp/test and /tmp/test2"
mkdir -p /tmp/test
mkdir -p /tmp/test2

cp ./Hello /tmp/test/
cp ./No_exec /tmp/test2/