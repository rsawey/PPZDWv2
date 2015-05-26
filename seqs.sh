#!/bin/bash
for ((a=1; a <= 3652 ; a++))
do
   echo "insert into dates values ('2455197.5' + $a);"
done
