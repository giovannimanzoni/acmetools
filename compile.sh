#!/bin/bash
#
#
# Use this script for compile the system and prepare all files for the micro sd.
# The script will ask you what is your target (Acme Systems board name)
# and it will propose what you can choose (as kernel version)
# and it will use the right rootfs that is needed (Debian Jessie / Debian Wheezy)
#
# Creative Commons License
# This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
# Author: Giovanni Manzoni (commerciale@hardelettrosoft.com)
# Based on work of : Sergio Tanzilli (sergio@tanzilli.com)
#

WORKING_DIR=$(pwd)
LOG_FILE='compile.log'
POINTER= #function return values
BOOTPARTITIONNAME= # boot or BOOT

function addlog () {
	echo "$(date)   | $1" >> $WORKING_DIR/$LOG_FILE
}

function checknumber () {
local NUM=$1
	if ! [ "$NUM" -eq "$NUM" ] 2>/dev/null; then
		wrong
	fi
}

function read_yn {
        local YN=''
        until [[ $YN =~ ^(y|n|Y|N)$ ]]; do
                read -n 1 YN
                if [[ $YN =~ ^(y|Y)$ ]]; then
                        echo "-> Yes"
                elif [[ $YN =~ ^(n|N)$ ]]; then
                        echo "-> No"
                else
                        echo
                        echo "Please use only y/n/Y/N key"
                fi
        done
        POINTER=$YN
}


#for $BOARD
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
echo
echo "log will be saved in $WORKING_DIR/$LOG_FILE"
echo
touch $WORKING_DIR/$LOG_FILE
addlog "=============================="
addlog "S T A R T"
addlog "Board"

read -n 1 BOARD
if ! [[ "$BOARD" =~ ^[1-7]+$ ]]; then
	wrong
elif [ $BOARD -eq $ACQUA256 ]; then
	addlog "- Acqua 256M selected"
elif [ $BOARD -eq $ACQUA512 ]; then
	addlog "- Acqua 512M selected"
elif [ $BOARD -eq $ARIAG25128 ]; then
	addlog "- Aria G25 128M selected"
elif [ $BOARD -eq $ARIAG25256 ]; then
	addlog "- Aria G25 256M selected"
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	addlog "- Arietta G25 128M selected"
elif [ $BOARD -eq $ARIETTAG25256 ];  then
	addlog "- Arietta G25 256M selected"
elif [ $BOARD -eq $FOX ]; then
	addlog "- Fox G20 selected"
fi
echo
echo "Ok."
echo
sleep 1
}

#option for $KERNEL
readonly K4_2_6=1
readonly K4_1_11=2
readonly K3_18_14=3
readonly K3_16_1=4
readonly K3_10=5
readonly K2_6_39=6
readonly K2_6_38=7

function kernelnotpresent () {
	echo
	echo "This kernel is not present on disk"
	echo
}

function validatek () {
	VERSION=$1
	if [ $VERSION -eq $K4_2_6 ] && [ ! -d kernel/linux-4.2.6 ]; then
		kernelnotpresent
		addlog "Kernel 4.2.6 is not present on the disk"
		exit
	elif [ $VERSION -eq $K4_1_11 ] && [ ! -d kernel/linux-4.1.11 ]; then
		kernelnotpresent
		addlog "Kernel 4.1.11 is not present on the disk"
		exit
	elif [ $VERSION -eq $K3_18_14 ] && [ ! -d kernel/linux-3.18.14 ]; then
		kernelnotpresent
		addlog "Kernel 3.18.14 is not present on the disk"
		exit
	elif [ $VERSION -eq $K3_16_1 ] && [ ! -d kernel/linux-3.16.1 ]; then
		kernelnotpresent
		addlog "Kernel 3.16.1 is not present on the disk"
		exit
	elif [ $VERSION -eq $K3_10 ] && [ ! -d kernel/linux-3.10 ]; then
		kernelnotpresent
		addlog "Kernel 3.10 is not present on the disk"
		exit
	elif [ $VERSION -eq $K2_6_39 ] && [ ! -d kernel/linux-2.6.39 ]; then
		kernelnotpresent
		addlog "Kernel 2.6.39 is not present on the disk"
		exit
	elif [ $VERSION -eq $K2_6_38 ] && [ ! -d kernel/linux-2.6.38 ]; then
		kernelnotpresent
		addlog "Kernel 2.6.38 is not present on the disk"
		exit
	fi
}


function menukernel {
echo
echo
echo "Which kernel version do you want ?"
echo
if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "5: 3.10"
	echo
	read -n 1 KERNEL
	validatek $KERNEL
	if ! ([ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 5 ]); then
		wrong
	fi
elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "3: 3.18.14"
	echo "4: 3.16.1"
	echo "6: 2.6.39"
	echo
	read -n 1 KERNEL
	validatek $KERNEL
	if ! ([ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 3 ] || [ $KERNEL -eq 4 ] || [ $KERNEL -eq 6 ]); then
		wrong
	fi
elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "3: 3.18.14"
	echo "4: 3.16.1"
	echo
	read -n 1 KERNEL
	validatek $KERNEL
	if ! ([ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 3 ] || [ $KERNEL -eq 4 ]); then
		wrong
	fi
elif [ $BOARD -eq $FOX ]; then
	echo "7: 2.6.38"
	echo
	read -n 1 KERNEL
	validatek $KERNEL
	if [ $KERNEL -ne 7 ]; then
		wrong
	fi
else
	wrong
fi
echo
echo "Ok."
sleep 1
}


function compilebootloader {
local MAKEDEFCONFIG=0
echo
echo
echo "Bootloader section"
echo
echo
addlog "Bootloader"
sleep 1
cd bootloader
if [ $BOARD -eq $ACQUA256 ]; then
	cd at91bootstrap-3.7-acqua-256m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make acqua-256m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -eq $ACQUA512 ]; then
	cd at91bootstrap-3.7-acqua-512m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make acqua-512m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -eq $ARIAG25128 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-128m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make aria-128m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -eq $ARIAG25256 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-256m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make aria-256m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	cd at91bootstrap-3.7-arietta-128m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make arietta-128m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -eq $ARIETTAG25256 ];  then
	cd at91bootstrap-3.7-arietta-256m
	if [ ! -f .config ]; then
		addlog "- Create default configuration"
		make arietta-256m_defconfig
		MAKEDEFCONFIG=1
	fi
elif [ $BOARD -ne $FOX ];then
	echo
	echo "Board error"
	echo
	addlog "Board error"
	exit
fi

#above and below if must be separated
if [ $BOARD -eq $FOX ] && [ $KERNEL -eq $K2_6_38 ]; then
	cd acmeboot
	nano cmdline.txt
	nano macaddress.txt
elif ([ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]) && [ $KERNEL -eq $K2_6_39 ]; then
	cd AriaBoot
	echo "Now you can change some parameters of bootloader."
	echo
	echo "For 128MB of ram, you have to set CONFIG_LINUX_KERNEL_ARG_STRING to"
	echo "mem=128M console=ttyS0,115200 noinitrd root=/dev/mmcblk0p2 rw rootwait init=/sbin/init"
	echo "For 256MB of ram, you have to set CONFIG_LINUX_KERNEL_ARG_STRING to"
	echo "mem=256M console=ttyS0,115200 noinitrd root=/dev/mmcblk0p2 rw rootwait init=/sbin/init"
	echo
	echo "Please press any key to open shell editor"
	read -n 1 KEY
	echo
#	SHA1=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
	nano .config
#	SHA2=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
#	if [ "$SHA1" != "$SHA2" ]; then
#		addlog "- Create new verson of bootloader"
		make
#		addlog "- Creation ok."
#	else
#		addlog "- Booloader configuration has not changed"
#	fi
	echo
elif [ $BOARD -eq $FOX ] && [ $KERNEL -eq $K2_6_38 ]; then
	cd acmeboot
	nano macaddress.txt
else
	#for all other
#	SHA1=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
#	SHA2=$SHA1
	echo
	echo "Would you edit bootloader configuration ? y/n/Y/N"
	echo
	read_yn; EDIT=$POINTER

	if [[ $EDIT =~ ^(y|Y)$ ]]; then
		make menuconfig
		addlog "- Menu config was opened."
#		SHA2=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
#		if [ "$SHA1" != "$SHA2" ]; then
#			addlog "  - Bootloader configuration is not changed."
#		else
#			addlog "  - But Configuration has not changed."
#		fi
#	else
#		addlog "- Bootloader configuration has not changed."
	fi

#	if ([ "$SHA1" != "$SHA2" ] || [ $MAKEDEFCONFIG -eq 1 ]);then
		echo
		echo "compile bootloader"
		echo
		addlog "  - Compiling start"
		make CROSS_COMPILE=arm-linux-gnueabi-
		addlog "  - Compiling end"
#	fi


fi
#exit from specific bootloader folder
cd ..
#exit from bootloader
cd ..

}

function theend {
	echo
	echo "The End"
	echo
}

function wrong {
	echo
	echo "Wrong value ! !"
	echo
	exit
}

function compilekernel {
	addlog "Kernel"

	if   [ $KERNEL -eq $K4_2_6 ]; then
		echo
		echo
		echo "K E R N E L   4 . 2 . 6"
		echo
		echo
		addlog "- Version 4.2.6"
		cd kernel/linux-4.2.6
	elif [ $KERNEL -eq $K4_1_11 ]; then
		echo
		echo
		echo "K E R N E L   4 . 1 . 1 1"
		echo
		echo
		addlog "- Version 4.1.11"
		cd kernel/linux-4.1.11
	elif [ $KERNEL -eq $K3_18_14 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 8 . 1 4"
		echo
		echo
		addlog "- Version 3.18.14"
		cd kernel/linux-3.18.14
	elif [ $KERNEL -eq $K3_16_1 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 6 . 1"
		echo
		echo
		addlog "- Version 3.16.1"
		cd kernel/linux-3.16.1
	elif [ $KERNEL -eq $K3_10 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 0"
		echo
		echo
		addlog "- Version 3.10"
		cd kernel/linux-3.10
	elif [ $KERNEL -eq $K2_6_39 ]; then
		echo
		echo
		echo "K E R N E L   2 . 6 . 3 9"
		echo
		echo
		addlog "- Version 2.6.39"
		cd kernel/linux-2.6.39
	elif [ $KERNEL -eq $K2_6_38 ]; then
		echo
		echo
		echo "K E R N E L   2 . 6 . 3 8"
		echo
		echo
		addlog "- Version 2.6.38"
		cd kernel/foxg20-linux-2.6.38
	else
		wrong
	fi
	sleep 1

	#add under git
	echo
	echo "Add files under git for safety"
	echo
	addlog "- Add files under git for safety"
	git add .
	if [ -f .config ]; then
		git add -f .config
	fi
	git commit -m "keep under git for safety"
	echo
	sleep 2

	#manage .config
	#delete .config
	if [ -f .config ]; then
		echo
		echo "Kernel Menu Config will be opened in next step."
		echo
		echo "What would you like about kernel configuration (.config) ?"
		echo "1: delete, so clean, make default and modify if you like"
		echo "2: modify, so keep .config & clean generated files"
		echo "3: nothing to do, so do not recompile kernel, already done in the past"
		echo
		read -n 1 KERNEL_CONFIG
		echo
		echo "Ok."
		echo
		#check if it is a number
		checknumber $KERNEL_CONFIG
		if [ $KERNEL_CONFIG -eq 1 ]; then
			addlog "- Delete .config and all generated files"
			make ARCH=arm mrproper
		# 3 but if .config do not exist !!
		elif [ $KERNEL_CONFIG -eq 3 ] && [ ! -f .config ]; then
			echo
			echo "But .config do not exist, no previous configuration found !"
			echo
			addlog "- Keep previous kernel configuration but it do not exist. Exit"
			exit
		elif [ $KERNEL_CONFIG -eq 3 ] && [ -f .config ]; then
			addlog "- Kernel built in the past"
		elif [ $KERNEL_CONFIG -ne 2 ]; then
			addlog "- Wrong value ( $KERNEL_CONFIG ) in what to do about kernel configuration"
			wrong
		fi
		CONFIG_DEF=0 # do not use default config file
	fi
	# must be two separated if, .config can be deleted if exist  by option 1 above
	if [ ! -f .config ]; then
		KERNEL_CONFIG=1 #make default config file
		#default config file not exist, create from default
		CONFIG_DEF=1
		echo
		echo "Create default config file"
		echo
		addlog "- Create default config file from Acme Systems defconfig"
		if [ $KERNEL -eq $K4_1_11 ]; then
			if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta-g25_defconfig
			elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria-g25_defconfig
			elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua-a5_defconfig
			fi
		elif [ $KERNEL -eq $K2_6_38 ]; then
			echo #nothing to do
		elif [ $KERNEL -eq $K2_6_39 ]; then
			echo #nothing to do
		elif [ $BOARD -ne $FOX ]; then
			if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta_defconfig
			elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria_defconfig
			elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
				make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua_defconfig
			fi
		else
			make foxg20_defconfig
		fi
	fi
	sleep 1

	#compile kernel
	if [ $BOARD -eq $FOX ]; then
		if [ $KERNEL_CONFIG -ne 3 ]; then
			make menuconfig
			addlog "- Kernel menuconfig was opened"
			sleep 1
			addlog "- Kernel compiling start"
			make -j8
			addlog "- Kernel compiling end"
			echo
			echo
			echo
			addlog "- Kernel modules compiling start"
			make modules -j8
			addlog "- Kernel modules compiling end"
			echo
			echo
			echo
			rm -rf ./foxg20-modules # for safety
			addlog "- Kernel modules install start"
			make modules_install
			addlog "- Kernel modules install end"
		fi
	else
		if [ $KERNEL_CONFIG -ne 3 ]; then # 1 or 2

#	 		SHA1=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
			KERNEL_MENU=0
			if [ $KERNEL_CONFIG -eq 1 ]; then
				echo
				echo "Would you modify kernel configuration ? y/n/Y/N"
				echo
				read_yn; KERNEL_MENU=$POINTER
			fi
			if ([[ $KERNEL_MENU =~ ^(y|Y)$ ]] || [ $KERNEL_CONFIG -eq 2 ]); then
				make ARCH=arm xconfig
				addlog "- Kernel menu config was opened for change kernel configuration"
			fi
#			SHA2=$(NEW_SUM=`find .config  -print0| xargs -0 du -b --time  | sort -k4,4 | sha1sum | awk '{print $1}'`)
			# if .config is changed or is created for first time
#			if [ "$SHA1" != "$SHA2" ] || [ $CONFIG_DEF -eq 1 ]; then
#				if [ "$SHA1" != "$SHA2" ]; then
#					addlog "  - Kernel configuration was changed"
#				else # SHA1 = SHA2  && $CONFIG_DEF = 1
#					echo
#					echo "Kernel configuration is not changed"
#					echo
#					addlog "  - Kernel configuration is not changed"
#				fi
				if [ $KERNEL_CONFIG -eq 2 ]; then
					make ARCH=arm clean
					addlog "  - Clean generated files in kernel folder but keep kernel configuration (.config)"
				fi
				sleep 1
				addlog "- Kernel compiling start"
				make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
				make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- zImage
				addlog "- Kernel compiling end"
				echo
				echo
				echo
				addlog "- Kernel modules compiling start"
				make modules -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
				addlog "- Kernel modules compiling end"
				echo
				echo
				echo
				addlog "- Kernel modules install start"
				make modules_install INSTALL_MOD_PATH=./modules ARCH=arm
				addlog "- Kernel modules install end"
#			else
#				echo
#				echo "Kernel configuration is not changed"
#				echo
#				addlog "  - But kernel configuration is not changed"
#			fi
		fi
	fi

	#compile dtb
	echo
	echo "Would you like edit the device tree (.dts) ? y/n/Y/N"
	echo
	read_yn; DTB_MOD=$POINTER
	if [ $KERNEL -eq $K4_1_11 ]; then
		if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-arietta-g25.dts
			fi
			# do always, small cpu time, absent if make clean on kernel folder
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta-g25.dtb
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-aria-g25.dts
			fi
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria-g25.dtb
		elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-acqua-a5.dts
			fi
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua-a5.dtb
		fi
	else
		if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-arietta.dts
			fi
			# do always, small cpu time, absent if make clean on kernel folder
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta.dtb
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-aria.dts
			fi
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria.dtb
		elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
				nano arch/arm/boot/dts/acme-acqua.dts
			fi
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua.dtb
		fi
	fi
	if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
		addlog "- Editor for device tree was opened"
	else
		addlog "- Device tree was not edited"
	fi
	echo
	echo
	echo
	#exit from specific kernel folder
	cd ..
	#exit from kernel folder
	cd ..
}

function copyfiles {
	echo
	echo
	echo "Insert right partitioned micro sd and Press Enter for copy files on it"
	echo "visit  http://www.acmesystems.it/microsd_format  for how do it"
	echo
	read KEY
	if [ -d /media/$USER/boot ];then
		BOOTPARTITIONNAME='boot'
	elif  [ -d /media/$USER/BOOT ];then
		BOOTPARTITIONNAME='BOOT'
	else
		echo
		echo "Boot partition not found"
		echo
		addlog "Boot partition not found"
		exit
	fi
	copybootloader
	copyrootfs
	copykernel
}

function copybootloader {
	echo
	echo
	echo "Copy the bootloader on the micro sd"
	echo
	echo
	sleep 1
	if [ $BOARD -eq $ACQUA256 ]; then
		cp bootloader/at91bootstrap-3.7-acqua-256m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $ACQUA512 ]; then
		cp bootloader/at91bootstrap-3.7-acqua-512m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $ARIAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-aria-128m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $ARIAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-aria-256m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $ARIETTAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-128m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $ARIETTAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-256m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/$BOOTPARTITIONNAME/boot.bin
	elif [ $BOARD -eq $FOX ]; then
		echo
		echo "Leaving the FOX Board G20 off. Connect the FOX Board G20 debug port using the DPI adapter and check if the usbserial module driver for the DPI chip is correctly installed (typing dmesg in a second shell)"
		echo
		echo "Do you have serialflash [1] or dataflash [2] (http://www.acmesystems.it/netus_memories) ?"
		echo
		read -n 1 KEY
		if [ $KEY -eq 1  ]; then
			sudo python pizzica.py -f acmeboot_serialflash_1.22.bin -d /dev/ttyUSB0
		elif [ $KEY -eq 2  ]; then
			sudo python pizzica.py -f acmeboot_dataflash_1.22.bin -d /dev/ttyUSB0
		else
			wrong
		fi
		echo "Plug the DPI on the FOX debug port and close the two contacts shown below on the Netus G20 module with something metallic, turn-on the board and immediately after that, release the two contacts. In that way the internal RomBOOT will start and Pizzica will be able to comunicate with it. The two contacts have not to be kept closed after switching the FoxG20 on, otherwise the DataFlash will not be reprogrammed"
		echo
		echo "Remove the contacts and see the message sent by Pizzica"
	else
		wrong
	fi
}

function copyrootfs {
	echo
	echo
	echo "Copy the root file system on the micro sd"
	echo
	echo
	addlog "Rootfs"
	sleep 1
	if [ $KERNEL -eq $K2_6_38 ] || [ $KERNEL -eq $K2_6_39 ] || [ $KERNEL -eq $K3_10 ] || [ $KERNEL -eq $K3_16_1 ] || [ $KERNEL -eq $K3_18_14 ]; then
		addlog "- Rootfs with Debian Wheezy"
		if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/acqua/target-rootfs/ /media/$USER/rootfs/
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/aria/target-rootfs/ /media/$USER/rootfs/
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/arietta/target-rootfs/ /media/$USER/rootfs/
		fi
	else
		#for newer kernel
		if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			echo
			echo "Whould you like use old Debian Wheezy y/n/Y/N ? If no, Debian Jessie will be used"
			echo
			read_yn; USE_WHEEZY=$POINTER
			if [[ $USE_WHEEZY =~ ^(y|Y)$ ]]; then
				addlog "- Rootfs with Debian Wheezy"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/acqua/target-rootfs/ /media/$USER/rootfs/
			else
				addlog "- Rootfs with Debian Jessie"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/acqua/target-rootfs/ /media/$USER/rootfs/
			fi
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			echo
			echo "Whould you like use old Debian Wheezy y/n/Y/N ? If no, Debian Jessie will be used"
			echo
			read_yn; USE_WHEEZY=$POINTER
			if [[ $USE_WHEEZY =~ ^(y|Y)$ ]]; then
				addlog "- Rootfs with Debian Wheezy"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/aria/target-rootfs/ /media/$USER/rootfs/
			else
				addlog "- Rootfs with Debian Jessie"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/aria/target-rootfs/ /media/$USER/rootfs/
			fi
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			echo
			echo "Whould you like use old Debian Wheezy y/n/Y/N ? If no, Debian Jessie will be used"
			echo
			read_yn; USE_WHEEZY=$POINTER
			if [[ $USE_WHEEZY =~ ^(y|Y)$ ]]; then
				addlog "- Rootfs with Debian Wheezy"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/arietta/target-rootfs/ /media/$USER/rootfs/
			else
				addlog "- Rootfs with Debian Jessie"
				sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/arietta/target-rootfs/ /media/$USER/rootfs/
			fi
		fi
	fi
}

function copykernel {
	echo
	echo
	echo "Copy the kernel on the micor sd"
	echo
	echo
	addlog "- Copy kernel files on the micro sd"
	sleep 1

	if   [ $KERNEL -eq $K4_2_6 ]; then
		cd kernel/linux-4.2.6/
	elif [ $KERNEL -eq $K4_1_11 ]; then
		cd kernel/linux-4.1.11/
	elif [ $KERNEL -eq $K3_18_14 ]; then
		cd kernel/linux-3.18.14/
	elif [ $KERNEL -eq $K3_16_1 ]; then
		cd kernel/linux-3.16.1/
	elif [ $KERNEL -eq $K3_10 ]; then
		cd kernel/linux-3.10/
	elif [ $KERNEL -eq $K2_6_39 ]; then
		cd kernel/linux-2.6.39/
	elif [ $KERNEL -eq $K2_6_38 ]; then
		cd kernel/linux-2.6.38/
	else
		wrong
	fi
	if [ $KERNEL -eq $K4_1_11 ]; then
		if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			cp arch/arm/boot/dts/acme-acqua-a5.dtb /media/$USER/$BOOTPARTITIONNAME/at91-sama5d3_acqua.dtb
			cp arch/arm/boot/dts/acme-acqua-a5.dts /media/$USER/$BOOTPARTITIONNAME/at91-sama5d3_acqua.dts
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			cp arch/arm/boot/dts/acme-aria-g25.dtb /media/$USER/$BOOTPARTITIONNAME/at91-ariag25.dtb
			cp arch/arm/boot/dts/acme-aria-g25.dts /media/$USER/$BOOTPARTITIONNAME/at91-ariag25.dts
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			cp arch/arm/boot/dts/acme-arietta-g25.dtb /media/$USER/$BOOTPARTITIONNAME/acme-arietta.dtb
			cp arch/arm/boot/dts/acme-arietta-g25.dts /media/$USER/$BOOTPARTITIONNAME/acme-arietta.dts
		fi
	else
		if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			cp arch/arm/boot/dts/acme-acqua.dtb /media/$USER/$BOOTPARTITIONNAME/at91-sama5d3_acqua.dtb
			cp arch/arm/boot/dts/acme-acqua.dts /media/$USER/$BOOTPARTITIONNAME/at91-sama5d3_acqua.dts
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			cp arch/arm/boot/dts/acme-aria.dtb /media/$USER/$BOOTPARTITIONNAME/at91-ariag25.dtb
			cp arch/arm/boot/dts/acme-aria.dts /media/$USER/$BOOTPARTITIONNAME/at91-ariag25.dts
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			cp arch/arm/boot/dts/acme-arietta.dtb /media/$USER/$BOOTPARTITIONNAME/acme-arietta.dtb
			cp arch/arm/boot/dts/acme-arietta.dts /media/$USER/$BOOTPARTITIONNAME/acme-arietta.dts
		fi
	fi

	local IMGEXIST=0
	if [ -f arch/arm/boot/uImage ];then
		IMGEXIST=1
		cp arch/arm/boot/uImage /media/$USER/$BOOTPARTITIONNAME/image.bin #for at91bootloader configured for uImage
	fi
	if [ -f arch/arm/boot/zImage ];then
		IMGEXIST=1
		cp arch/arm/boot/zImage /media/$USER/$BOOTPARTITIONNAME
	fi
	if [ $IMGEXIST -eq 0 ];then
		echo "No kernel image found !"
		addlog "No kernel image found !"
		exit
	fi
	sudo rsync -avc modules/lib/. /media/$USER/rootfs/lib/.
	#exit from this kernel
	cd ..
	#exit from kernel folder
	cd ..
}

function umountmemory {
	echo
	echo "Remember to do depmod -a on target"
	echo
	echo "sync files. . . Please wait"
	echo
	sync
	sudo umount /media/$USER/$BOOTPARTITIONNAME
	sudo umount /media/$USER/rootfs
	sudo umount /media/$USER/data
	echo
	echo "You can safety remove the micro sd"
	echo

}

function bootloadernotpresent () {
	echo
	echo "This bootloader is not present on the disk"
	echo
	exit
}

#validate bootloader by match with kernel & board
function validateb () {
	if [ $BOARD -eq $ACQUA256 ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-acqua-256m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $ACQUA512 ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-acqua-512m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIAG25128 ] && [ $KERNEL -ne $K2_6_38 ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-aria-128m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIAG25256 ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-aria-256m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIETTAG25128 ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-arietta-128m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIETTAG25256 ];  then
		if [ ! -d  bootloader/at91bootstrap-3.7-arietta-256m ]; then
			bootloadernotpresent
		fi
	elif [ $BOARD -eq $FOX ]; then
		if [ ! -d  bootloader/at91bootstrap-3.7-acqua-512m ]; then
			bootloadernotpresent
		fi
	fi
}


#
# P R O G R A M
#

if [ "$USER" == "root" ];then
	echo
	echo "exit from root"
	echo
	exit
fi
if [ ! -f /home/$USER/.gitconfig]; then
	echo
	echo "You have to configure git by do these commands:"
	echo
	echo 'git config --global user.email "your@email.com"'
	echo 'git config --global user.name "your name"'
	echo
	exit
fi

menuboard
menukernel
validateb #validate bootloader
compilebootloader
compilekernel
copyfiles
umountmemory
cat compile.log
theend


