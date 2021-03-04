#!/bin/bash


RED="\033[1;31m"
GREY="\033[1;90m"
ENDC="\033[0m"
OKGREEN="\033[1;92m"
BLUE="\033[1;94m"
BLACK="\033[1;95m"
RR="\033[1;93m"
RRR="\033[1;96m"

colors=($RED $GREY $OKGREEN $BLUE $BLACK $RR $RRR)

echo " ______   ______   _______ _________         "  
echo "(  __  \ / ___  \ (  ___  )\__   __/|\     /|"
echo "| (  \  )\/   \  \| (   ) |   ) (   | )   ( |"
echo "| |   ) |   ___) /| (___) |   | |   | (___) |"
echo "| |   | |  (___ ( |  ___  |   | |   |  ___  |"
echo "| |   ) |      ) \| (   ) |   | |   | (   ) |"
echo "| (__/  )/\___/  /| )   ( |   | |   | )   ( |"
echo "(______/ \______/ |/     \|   )_(   |/     \|"
echo -e "$GREY This script only purpose is to test Death virus$ENDC \n"


while true; do
echo -e "1 : Create DIR && Copy binary"
echo -e "2 :$RED Launch Death$ENDC"
echo -e "3 :$BLUE analyze signature$ENDC"
echo -e "4 :$OKGREEN Anti debug GDB.$ENDC"
echo -e "5 : launch 'test' process"
echo -e "6 : kill 'test' process"
echo -e "7 :$BLACK Compare same binary for metamorphic code$ENDC"
echo -e "8 : exit"

echo "Choice?"
read choice
if [ $choice -eq 8 ]
then
	exit 0
fi
if [ $choice -eq 1 ]
then
	clear
	echo "rm -rf /tmp/test/ /tmp/test2 && mkdir -p /tmp/test/ /tmp/test2"
	rm -rf /tmp/test/ /tmp/test2 && mkdir -p /tmp/test/ /tmp/test2
	echo "cp /bin/ls /bin/bash /tmp/test/ && cp /bin/ls /bin/bash /tmp/test2\n\n"
	echo "echo "AAAAAAAAAAAAAAAAAA" > /tmp/test/a"
	echo "AAAAAAAAAAAAAAAAAAAAAAAA" > /tmp/test/a
	cp /bin/ls /bin/bash /pwd/bin/Hello /tmp/test/ && cp /bin/ls /pwd/bin/Hello /bin/bash /tmp/test2
	echo
fi
if [ $choice -eq 2 ]
then
	clear
	echo "cd /pwd && make re > /dev/null 2>&1 && mv Death / && cd / && ./Death"
	cd /pwd && make re > /dev/null 2>&1 && mv Death / && cd / && ./Death
	echo
fi
if [ $choice -eq 3 ]
then
	clear
	echo "Analysing SIGNATURE"
	for file in /tmp/test/*
	do
		n=$(($RANDOM % 7))
		echo -ne ${colors[$n]}
		sig=$(strings $file | grep "dbaffier")
		printf "%-20s => %-40s\n" $file "$sig"
		echo -ne $ENDC
	done
	echo
	for file in /tmp/test2/*
	do
		n=$(($RANDOM % 7))
		echo -ne ${colors[$n]}
		sig=$(strings $file | grep "dbaffier")
		printf "%-20s => %-40s\n" $file "$sig"
		echo -ne $ENDC
	done
	echo
fi
if [ $choice -eq 4 ]
then
	clear
	echo "echo -e \"run > outfile\nq\" > cmd && gdb -q /Death -x cmd && cat outfile && rm outfile cmd"
	echo -e "run > outfile\nq" > cmd && gdb -q /Death -x cmd && cat outfile && rm outfile cmd
	echo
fi
if [ $choice -eq 5 ]
then
	clear
	echo "cd /pwd/bin && ./test &"
	cd /pwd/bin ; ./test &
fi
if [ $choice -eq 6 ]
then
	clear
	echo "kill -9 $(pgrep test)"
	kill -9 $(pgrep test)
fi
if [ $choice -eq 7 ]
then
	clear
	echo "rm -rf /tmp/test/ /tmp/test2 && mkdir -p /tmp/test/ /tmp/test2"
	rm -rf /tmp/test/ /tmp/test2 && mkdir -p /tmp/test/ /tmp/test2
	echo "cp /bin/ls /tmp/test/ls1 && cp /bin/ls /tmp/test/ls2 && cp /bin/ls /tmp/test/ls3 && cp/bin/ls /tmp/test/ls4"
	cp /bin/ls /tmp/test/ls1 && cp /bin/ls /tmp/test/ls2 && cp /bin/ls /tmp/test/ls3 && cp /bin/ls /tmp/test/ls4
	echo
	echo "cd /pwd && make re > /dev/null 2>&1 && mv Death / && cd / && ./Death"
	cd /pwd && make re > /dev/null 2>&1 && mv Death / && cd / && ./Death
	echo
	echo "xxd -c 16 -s +64 -l 4096 /tmp/test/ls1 > dump1"
	xxd -c 16 -s +64 -l 4096 /tmp/test/ls1 > dump1
	echo "xxd -c 16 -s +64 -l 4096 /tmp/test/ls2 > dump2"
	xxd -c 16 -s +64 -l 4096 /tmp/test/ls2 > dump2
	echo "xxd -c 16 -s +64 -l 4096 /tmp/test/ls3 > dump3"
	xxd -c 16 -s +64 -l 4096 /tmp/test/ls3 > dump3
	echo "xxd -c 16 -s +64 -l 4096 /tmp/test/ls4 > dump4"
	xxd -c 16 -s +64 -l 4096 /tmp/test/ls4 > dump4
	echo
	printf "/tmp/test/ls1 and /tmp/test/ls2 differ by : $RED%s\n$ENDC" $(radiff2 -c dump1 dump2)
	printf "/tmp/test/ls1 and /tmp/test/ls3 differ by : $RED%s\n$ENDC" $(radiff2 -c dump1 dump3)
	printf "/tmp/test/ls1 and /tmp/test/ls4 differ by : $RED%s\n$ENDC" $(radiff2 -c dump1 dump4)
	echo
	printf "/tmp/test/ls2 and /tmp/test/ls3 differ by : $OKGREEN%s\n$ENDC" $(radiff2 -c dump2 dump3)
	printf "/tmp/test/ls2 and /tmp/test/ls4 differ by : $OKGREEN%s\n$ENDC" $(radiff2 -c dump2 dump4)
	echo
	rm -rf /dump1 /dump2 /dump3 /dump4
	
fi
done
