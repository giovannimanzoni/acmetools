#!/bin/bash
#

readonly ACQUA256=1
readonly ACQUA512=2
readonly ARIAG25128=3
readonly ARIAG25256=4
readonly ARIETTAG25128=5
readonly ARIETTAG25256=6
readonly FOX=7

function menuboard {
echo
echo
echo "For witch Acme Systems board you want create the files ?"
echo "1: Acqua A5 256M"
echo "2: Acqua A5 512M"
echo "3: Aria G25 128M"
echo "4: Aria G25 256M"
echo "5: Arietta G25 128M"
echo "6: Arietta G25 256M"
echo "7: Fox G20"
read BOARD
echo
}

readonly K4_2_6=1

function menukernel {
echo
echo
echo "Which kernel version do you want ?"
read KERNEL
echo
}


function compileat91bootstrap {
echo
echo
echo "Start compilation of at91 bootstrap"
echo
echo
sleep 1

if [ $BOARD -eq $ACQUA256 ]; then
	echo "option 1"
	#cd at91bootstrap-3.7-acqua-256m
	#make acqua-256m_defconfig
elif [ $BOARD -eq $ACQUA512 ]; then
	echo "option 2"
	#cd at91bootstrap-3.7-acqua-512m
	#make acqua-512m_defconfig
elif [ $BOARD -eq $ARIAG25128 ]; then
	echo "aria 128"
	#cd at91bootstrap-3.7-aria-128m
	#make aria-128m_defconfig
elif [ $BOARD -eq $ARIAG25256 ]; then
	echo "aria 256"
	#cd at91bootstrap-3.7-aria-256m
	#make aria-256m_defconfig
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	echo "aritta 128"
	#cd at91bootstrap-3.7-arietta-128m
	#make arietta-128m_defconfig
elif [ $BOARD -eq $ARIETTAG25256 ]; then
	echo "aritta 256"
	#cd at91bootstrap-3.7-arietta-256m
	#make arietta-256m_defconfig
elif [ $BOARD -eq $FOX ]; then
	echo "fox"
else
	echo "wrong vlaue"
	exit
fi
#make menuconfig
#make CROSS_COMPILE=arm-linux-gnueabi-
#cd ..
}

function theend {
echo
echo "The End"
echo
}

menuboard
menukernel
compileat91bootstrap

theend

