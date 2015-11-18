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

LOG_FILE='compile.log'
POINTER= #function return values

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
echo "log saved in setup.log"
echo
touch $LOG_FILE
echo "==============================" >> $LOG_FILE
echo "$(date)   | S T A R T" >> $LOG_FILE
echo "$(date)   | Board" >> $LOG_FILE

read -n 1 BOARD
if ! [[ "$BOARD" =~ ^[1-7]+$ ]]; then
	wrong
elif [ $BOARD -eq $ACQUA256 ]; then
	echo "$(date)   | - Acqua 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $ACQUA512 ]; then
	echo "$(date)   | - Acqua 512M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIAG25128 ]; then
	echo "$(date)   | - Aria G25 128M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIAG25256 ]; then
	echo "$(date)   | - Aria G25 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	echo "$(date)   | - Arietta G25 128M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIETTAG25256 ];  then
	echo "$(date)   | - Arietta G25 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $FOX ]; then
	echo "$(date)   | - Fox G20 selected" >> $LOG_FILE
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
		echo "$(date)   | Kernel 4.2.6 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K4_1_11 ] && [ ! -d kernel/linux-4.1.11 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 4.1.11 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_18_14 ] && [ ! -d kernel/linux-3.18.14 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.18.14 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_16_1 ] && [ ! -d kernel/linux-3.16.1 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.16.1 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_10 ] && [ ! -d kernel/linux-3.10 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.10 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K2_6_39 ] && [ ! -d kernel/linux-2.6.39 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 2.6.39 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K2_6_38 ] && [ ! -d kernel/linux-2.6.38 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 2.6.38 is not present on the disk" >> $LOG_FILE
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
echo
echo
echo "Bootloader section"
echo
echo
echo "$(date)   | Bootloader" >> $LOG_FILE
sleep 1
cd bootloader
if [ $BOARD -eq $ACQUA256 ]; then
	cd at91bootstrap-3.7-acqua-256m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make acqua-256m_defconfig
	fi
elif [ $BOARD -eq $ACQUA512 ]; then
	cd at91bootstrap-3.7-acqua-512m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make acqua-512m_defconfig
	fi
elif [ $BOARD -eq $ARIAG25128 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-128m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make aria-128m_defconfig
	fi
elif [ $BOARD -eq $ARIAG25256 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-256m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make aria-256m_defconfig
	fi
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	cd at91bootstrap-3.7-arietta-128m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make arietta-128m_defconfig
	fi
elif [ $BOARD -eq $ARIETTAG25256 ];  then
	cd at91bootstrap-3.7-arietta-256m
	if [ ! -f .config ]; then
		echo "$(date)   | - Create default configuration" >> ../../$LOG_FILE
		make arietta-256m_defconfig
	fi
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
	SHA1=$(echo -n .config | sha256sum)
	nano .config
	SHA2=$(echo -n .config | sha256sum)
	if [ $SHA1 -ne $SHA2 ]; then
		echo "$(date)   | - Create new verson of bootloader" >> ../../$LOG_FILE
		make
		echo "$(date)   |   - Creation ok." >> ../../$LOG_FILE
	else
		echo "$(date)   | - Booloader configuration has not changed" >> ../../$LOG_FILE
	fi
	echo
elif [ $BOARD -eq $FOX ] && [ $KERNEL -eq $K2_6_38 ]; then
	cd acmeboot
	nano macaddress.txt
else
	#for all other
	SHA1=$(echo -n .config | sha256sum)
	echo
	echo "Would you edit bootloader configuration ? y/n/Y/N"
	echo
	read_yn; EDIT=$POINTER
	if [[ $EDIT =~ ^(y|Y)$ ]]; then
		make menuconfig
		echo "$(date)   | - Menu config was opened." >> ../../$LOG_FILE
		SHA2=$(echo -n .config | sha256sum)
		if [ $SHA1 -ne $SHA2 ]; then
			echo "$(date)   |   - Bootloader configuration is not changed." >> ../../$LOG_FILE
			echo "$(date)   |     - Compiling start" >> ../../$LOG_FILE
			make CROSS_COMPILE=arm-linux-gnueabi-
			echo "$(date)   |     - Compiling end" >> ../../$LOG_FILE
		else
			echo "$(date)   |   - But Configuration has not changed." >> ../../$LOG_FILE
		fi
	else
		echo "$(date)   |   - Bootloader configuration has not changed." >> ../../$LOG_FILE
	fi
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
	echo "$(date)   | Kernel" >> $LOG_FILE

	if   [ $KERNEL -eq $K4_2_6 ]; then
		echo
		echo
		echo "K E R N E L   4 . 2 . 6"
		echo
		echo
		echo "$(date)   | - Version 4.2.6" >> $LOG_FILE
		cd kernel/linux-4.2.6
	elif [ $KERNEL -eq $K4_1_11 ]; then
		echo
		echo
		echo "K E R N E L   4 . 1 . 1 1"
		echo
		echo
		echo "$(date)   | - Version 4.1.11" >> $LOG_FILE
		cd kernel/linux-4.1.11
	elif [ $KERNEL -eq $K3_18_14 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 8 . 1 4"
		echo
		echo
		echo "$(date)   | - Version 3.18.14" >> $LOG_FILE
		cd kernel/linux-3.18.14
	elif [ $KERNEL -eq $K3_16_1 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 6 . 1"
		echo
		echo
		echo "$(date)   | - Version 3.16.1" >> $LOG_FILE
		cd kernel/linux-3.16.1
	elif [ $KERNEL -eq $K3_10 ]; then
		echo
		echo
		echo "K E R N E L   3 . 1 0"
		echo
		echo
		echo "$(date)   | - Version 3.10" >> $LOG_FILE
		cd kernel/linux-3.10
	elif [ $KERNEL -eq $K2_6_39 ]; then
		echo
		echo
		echo "K E R N E L   2 . 6 . 3 9"
		echo
		echo
		echo "$(date)   | - Version 2.6.39" >> $LOG_FILE
		cd kernel/linux-2.6.39
	elif [ $KERNEL -eq $K2_6_38 ]; then
		echo
		echo
		echo "K E R N E L   2 . 6 . 3 8"
		echo
		echo
		echo "$(date)   | - Version 2.6.38" >> $LOG_FILE
		cd kernel/foxg20-linux-2.6.38
	else
		wrong
	fi
	sleep 1

	#add under git
	echo
	echo "Add files under git for safety"
	echo
	echo "$(date)   | - Add files under git for safety" >> ../../$LOG_FILE
	git add .
	git add -f .config
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
		if [ $KERNEL_CONFIG -eq 1 ]; then
			rm .config
			echo "$(date)   | - Delete .config" >> ../../$LOG_FILE
			make ARCH=arm mrproper
		# 3 but if .config do not exist !!
		elif [ $KERNEL_CONFIG -eq 3 ] && [ ! -f .config ]; then
			echo
			echo "But .config do not exist, no previous configuration found !"
			echo
			echo "$(date)   | - Keep previous kernel configuration but it do not exist. Exit" >> ../../$LOG_FILE
			exit
		elif [ $KERNEL_CONFIG -eq 3 ] && [ -f .config ]; then
			echo "$(date)   | - Kernel built in the past" >> ../../$LOG_FILE
		elif [ $KERNEL_CONFIG -ne 2 ]; then
			echo "$(date)   | - Wrong value ( $KERNEL_CONFIG ) in what to do about kernel configuration" >> ../../$LOG_FILE
			wrong
		fi
	fi
	#if not exist, create from default
	local CONFIG_DEFAULT=0
	if ! [ -f .config ]; then
		echo
		echo "Create default config file"
		echo
		echo "$(date)   | - Create default config file from Acme Systems defconfig" >> ../../$LOG_FILE
		if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta_defconfig
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria_defconfig
		elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua_defconfig
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			make foxg20_defconfig
		fi
		CONFIG_DEFAULT=1
	fi
	sleep 1

	#compile kernel
	if [ $BOARD -eq $FOX ]; then
		if [ $KERNEL_CONFIG -ne 3 ]; then
			make menuconfig
			echo "$(date)   | - Kernel menuconfig was opened" >> ../../$LOG_FILE
			sleep 1
			echo "$(date)   | - Kernel compiling start" >> ../../$LOG_FILE
			make -j8
			echo "$(date)   | - Kernel compiling end" >> ../../$LOG_FILE
			echo
			echo
			echo
			echo "$(date)   | - Kernel modules compiling start" >> ../../$LOG_FILE
			make modules -j8
			echo "$(date)   | - Kernel modules compiling end" >> ../../$LOG_FILE
			echo
			echo
			echo
			rm -rf ./foxg20-modules # for safety
			echo "$(date)   | - Kernel modules install start" >> ../../$LOG_FILE
			make modules_install
			echo "$(date)   | - Kernel modules install end" >> ../../$LOG_FILE
		fi
	else
		if [ $KERNEL_CONFIG -ne 3 ]; then # 1 or 2
			SHA1=$(echo -n .config | sha256sum)
			echo
			echo "Would you modify kernel configuration ?"
			echo
			read_yn; KERNEL_MENU=$POINTER
			if [[ $KERNEL_MENU =~ ^(y|Y)$ ]]; then
				make ARCH=arm menuconfig
				echo "$(date)   | - Kernel menu config was opened for change kernel configuration" >> ../../$LOG_FILE
			fi
			SHA2=$(echo -n .config | sha256sum)
			# if .config is changed or is created for first time
			if ([ $SHA1 -ne $SHA2 ] || [ $CONFIG_DEFAULT -eq 1  ])  ; then
				if [ $SHA1 -ne $SHA2 ]; then
					echo "$(date)   |   - Kernel configuration was changed" >> ../../$LOG_FILE
				fi
				if [ $KERNEL_CONFIG -eq 2 ]; then
					make ARCH=arm clean
					echo "$(date)   |   - Clean generated files in kernel folder but keep kernel configuration (.config)" >> ../../$LOG_FILE
				fi
				sleep 1
				echo "$(date)   |   - Kernel compiling start" >> ../../$LOG_FILE
				make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- zImage
				echo "$(date)   |   - Kernel compiling end" >> ../../$LOG_FILE
				echo
				echo
				echo
				echo "$(date)   |   - Kernel modules compiling start" >> ../../$LOG_FILE
				make modules -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
				echo "$(date)   |   - Kernel modules compiling end" >> ../../$LOG_FILE
				echo
				echo
				echo
				echo "$(date)   |   - Kernel modules install start" >> ../../$LOG_FILE
				make modules_install INSTALL_MOD_PATH=./modules ARCH=arm
				echo "$(date)   |   - Kernel modules install end" >> ../../$LOG_FILE
			else
				echo "$(date)   |   - But kernel configuration is not changed" >> ../../$LOG_FILE
			fi
		fi
	fi

	#compile dtb
	echo
	echo "Would you like edit the device tree (.dts) ? y/n/Y/N"
	echo
	read_yn; DTB_MOD=$POINTER
	if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
		if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
			nano arch/arm/boot/dts/acme-arietta.dts
		fi
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
	if [[ $DTB_MOD =~ ^(y|Y)$ ]]; then
		echo "$(date)   | - Editor for device tree was opened" >> ../../$LOG_FILE
	else
		echo "$(date)   | - Device tree was not edited" >> ../../$LOG_FILE
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
		cp bootloader/at91bootstrap-3.7-acqua-256m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
	elif [ $BOARD -eq $ACQUA512 ]; then
		cp bootloader/at91bootstrap-3.7-acqua-512m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
	elif [ $BOARD -eq $ARIAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-aria-128m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
	elif [ $BOARD -eq $ARIAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-aria-256m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
	elif [ $BOARD -eq $ARIETTAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-128m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
	elif [ $BOARD -eq $ARIETTAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-256m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/BOOT/boot.bin
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
	echo "$(date)   | Copy rootfs" >> $LOG_FILE
	sleep 1
	if [ $KERNEL -eq $K2_6_38 ] || [ $KERNEL -eq $K2_6_39 ] || [ $KERNEL -eq $K3_10 ] || [ $KERNEL -eq $K3_16_1 ] || [ $KERNEL -eq $K3_18_14 ]; then
		echo "$(date)   | Rootfs with Debian Wheezy" >> $LOG_FILE
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
				echo "$(date)   | Rootfs with Debian Wheezy" >> $LOG_FILE
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/acqua/target-rootfs/ /media/$USER/rootfs/
			else
				echo "$(date)   | Rootfs with Debian Jessie" >> $LOG_FILE
				sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/acqua/target-rootfs/ /media/$USER/rootfs/
			fi
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			echo
			echo "Whould you like use old Debian Wheezy y/n/Y/N ? If no, Debian Jessie will be used"
			echo
			read_yn; USE_WHEEZY=$POINTER
			if [[ $USE_WHEEZY =~ ^(y|Y)$ ]]; then
				echo "$(date)   | Rootfs with Debian Wheezy" >> $LOG_FILE
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/aria/target-rootfs/ /media/$USER/rootfs/
			else
				echo "$(date)   | Rootfs with Debian Jessie" >> $LOG_FILE
				sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/aria/target-rootfs/ /media/$USER/rootfs/
			fi
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			echo
			echo "Whould you like use old Debian Wheezy y/n/Y/N ? If no, Debian Jessie will be used"
			echo
			read_yn; USE_WHEEZY=$POINTER
			if [[ $USE_WHEEZY =~ ^(y|Y)$ ]]; then
				echo "$(date)   | Rootfs with Debian Wheezy" >> $LOG_FILE
				sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/arietta/target-rootfs/ /media/$USER/rootfs/
			else
				echo "$(date)   | Rootfs with Debian Jessie" >> $LOG_FILE
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

	if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
		cp arch/arm/boot/dts/acme-acqua.dtb /media/$USER/BOOT/at91-sama5d3_acqua.dtb
		cp arch/arm/boot/dts/acme-acqua.dts /media/$USER/BOOT/at91-sama5d3_acqua.dts
	elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
		cp arch/arm/boot/dts/acme-aria.dtb /media/$USER/BOOT/at91-ariag25.dtb
		cp arch/arm/boot/dts/acme-aria.dts /media/$USER/BOOT/at91-ariag25.dts
	elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
		cp arch/arm/boot/dts/acme-arietta.dtb /media/$USER/BOOT/acme-arietta.dtb
		cp arch/arm/boot/dts/acme-arietta.dts /media/$USER/BOOT/acme-arietta.dts
	fi

	cp arch/arm/boot/zImage /media/$USER/BOOT
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
	sudo umount /media/$USER/BOOT
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
			echo "fallisce"
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
menuboard
menukernel
validateb #validate bootloader
compilebootloader
compilekernel
copyfiles
umountmemory
cat compile.log
theend


