#!/bin/bash
#
#
# Use this script for compile the system and prepare all files for the micro sd.
# The script will ask you what is your target (Acme Systems board name)
# and it will propose what you can choose (as kernel version)
# and it will use the right rootfs that is needed (Jessie / Wheezy)
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
read -n 1 BOARD
if ! [[ "$BOARD" =~ ^[1-7]+$ ]]; then
	wrong
elif [ $BOARD -eq $ACQUA256 ]; then
	echo "$(date)   | Acqua 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $ACQUA512 ]; then
	echo "$(date)   | Acqua 512M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIAG25128 ]; then
	echo "$(date)   | Aria G25 128M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIAG25256 ]; then
	echo "$(date)   | Aria G25 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	echo "$(date)   | Arietta G25 128M selected" >> $LOG_FILE
elif [ $BOARD -eq $ARIETTAG25256 ];  then
	echo "$(date)   | Arietta G25 256M selected" >> $LOG_FILE
elif [ $BOARD -eq $FOX ]; then
	echo "$(date)   | Fox G20 selected" >> $LOG_FILE
fi
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
	if [ $VERSION -eq $K4_2_6 ] && [ ! -f kernel/linux-4.2.6 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 4.2.6 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K4_1_11 ] && [ ! -f kernel/linux-4.1.11 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 4.1.11 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_18_14 ] && [ ! -f kernel/linux-3.18.14 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.18.14 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_16_1 ] && [ ! -f kernel/linux-3.16.1 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.16.1 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K3_10 ] && [ ! -f kernel/linux-3.10 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 3.10 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K2_6_39 ] && [ ! -f kernel/linux-2.6.39 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 2.6.39 is not present on the disk" >> $LOG_FILE
		exit
	elif [ $VERSION -eq $K2_6_38 ] && [ ! -f kernel/linux-2.6.38 ]; then
		kernelnotpresent
		echo "$(date)   | Kernel 2.6.38 is not present on the disk" >> $LOG_FILE
		exit
	else
		echo
		echo "bug"
		echo
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
	read -n 1 KERNEL
	validatek $KERNEL
	if [ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 5 ]; then
		echo "Ok"
	else
		wrong
	fi
elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "3: 3.18.14"
	echo "4: 3.16.1"
	echo "6: 2.6.39"
	read -n 1 KERNEL
	validatek $KERNEL
	if [ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 3 ] || [ $KERNEL -eq 4 ] || [ $KERNEL -eq 6 ]; then
		echo "Ok"
	else
		wrong
	fi
elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "3: 3.18.14"
	echo "4: 3.16.1"
	read -n 1 KERNEL
	validatek $KERNEL
	if [ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 3 ] || [ $KERNEL -eq 4 ]; then
		echo "Ok"
	else
		wrong
	fi

elif [ $BOARD -eq $FOX ]; then
	echo "7: 2.6.38"
	read -n 1 KERNEL
	validatek $KERNEL
	if [ $KERNEL -eq 7 ]; then
		echo "Ok"
	else
		wrong
	fi
else
	wrong
fi
echo
sleep 1
}


function compilebootloader {
echo
echo
echo "Compiling the bootloader"
echo
echo
echo "$(date)   | Compiling the bootloader" >> $LOG_FILE
sleep 1
cd bootloader
if [ $BOARD -eq $ACQUA256 ]; then
	cd at91bootstrap-3.7-acqua-256m
	make acqua-256m_defconfig
elif [ $BOARD -eq $ACQUA512 ]; then
	cd at91bootstrap-3.7-acqua-512m
	make acqua-512m_defconfig
elif [ $BOARD -eq $ARIAG25128 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-128m
	make aria-128m_defconfig
elif [ $BOARD -eq $ARIAG25256 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-aria-256m
	make aria-256m_defconfig
elif [ $BOARD -eq $ARIETTAG25128 ] && [ $KERNEL -ne $K2_6_39 ]; then
	cd at91bootstrap-3.7-arietta-128m
	make arietta-128m_defconfig
elif [ $BOARD -eq $ARIETTAG25256 ] && [ $KERNEL -ne $K2_6_39 ];  then
	cd at91bootstrap-3.7-arietta-256m
	make arietta-256m_defconfig
elif [ $BOARD -eq $FOX ] && [ $KERNEL -ne $K2_6_38 ]; then
	cd acmeboot
	nano cmdline.txt
	nano macaddress.txt
elif ([ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]) && [ $KERNEL -eq $K2_6_39 ]; then
	cd AriaBoot
	echo "Now you can change some parameters of bootloader."
	echo "For 128MB of ram, you have to set CONFIG_LINUX_KERNEL_ARG_STRING to"
	echo "mem=128M console=ttyS0,115200 noinitrd root=/dev/mmcblk0p2 rw rootwait init=/sbin/init"
	echo "press any key to open shell editor"
	read -n 1 KEY
	echo
	nano .config
	make
	echo
elif [ $BOARD -eq $FOX ] && [ $KERNEL -eq $K2_6_38 ]; then
	cd acmeboot
	nano macaddress.txt
else
	#for all other
	make menuconfig
	make CROSS_COMPILE=arm-linux-gnueabi-
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
	echo
	echo
	echo "Compiling the kernel"
	echo
	echo
	sleep 1

	if   [ $KERNEL -eq $K4_2_6 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   4 . 2 . 6"
		echo
		echo
		echo "$(date)   | Compiling the kernel 4.2.6" >> $LOG_FILE
		cd kernel/linux-4.2.6
	elif [ $KERNEL -eq $K4_1_11 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   4 . 1 . 1 1"
		echo
		echo
		echo "$(date)   | Compiling the kernel 4.1.11" >> $LOG_FILE
		cd kernel/linux-4.1.11
	elif [ $KERNEL -eq $K3_18_14 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   3 . 1 8 . 1 4"
		echo
		echo
		echo "$(date)   | Compiling the kernel 3.18.14" >> $LOG_FILE
		cd kernel/linux-3.18.14
	elif [ $KERNEL -eq $K3_16_1 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   3 . 1 6 . 1"
		echo
		echo
		echo "$(date)   | Compiling the  kernel 3.16.1" >> $LOG_FILE
		cd kernel/linux-3.16.1
	elif [ $KERNEL -eq $K3_10 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   3 . 1 0"
		echo
		echo
		echo "$(date)   | Compiling the  kernel 3.10" >> $LOG_FILE
		cd kernel/linux-3.10
	elif [ $KERNEL -eq $K2_6_39 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   2 . 6 . 3 9"
		echo
		echo
		echo "$(date)   | Compiling the  kernel 2.6.39" >> $LOG_FILE
		cd kernel/linux-2.6.39
	elif [ $KERNEL -eq $K2_6_38 ]; then
		echo
		echo
		echo "C O M P I L I N G   T H E   K E R N E L   2 . 6 . 3 8"
		echo
		echo
		echo "$(date)   | Compiling the kernel 2.6.38" >> $LOG_FILE
		cd kernel/foxg20-linux-2.6.38
	else
		wrong
	fi
	sleep 1

	#manage .config
	#delete .config
	if [ -f .config ]; then
		echo
		echo "Would you like to delete current kernel configuration (.config file) and make default ? [y/n/Y/N]"
		echo
		read_yn; DELETE_CONFIG=$POINTER
		if [[ $DELETE_CONFIG =~ ^(y|Y)$ ]]; then
			rm .config
			echo "$(date)   | Delete .config" >> ../../$LOG_FILE
		fi
	fi
	#if not exist, create from default
	if [ ! -f .config ]; then
		echo
		echo "Create default config file"
		echo
		echo "$(date)   | Create default config file" >> ../../$LOG_FILE
		if [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-arietta_defconfig
		elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-aria_defconfig
		elif [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
			make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- acme-acqua_defconfig
		elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
			make foxg20_defconfig
		fi
	fi
	sleep 1

	#add under git
	echo
	echo
	echo "add files under git"
	echo "$(date)   | Add files under git" >> ../../$LOG_FILE
	git add .
	git add -f .config
	git commit -m "update"
	echo
	echo
	sleep 2
	#compile
	if [ $BOARD -eq $FOX ]; then
		make menuconfig
		sleep 1
		make -j8
		echo
		echo
		echo
		make modules -j8
		echo
		echo
		echo
		rm -rf ./foxg20-modules # for safety
		make modules_install
	else
		make ARCH=arm menuconfig
		sleep 1
		make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- zImage
		echo
		echo
		echo
		make modules -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
		echo
		echo
		echo
		make modules_install INSTALL_MOD_PATH=./modules ARCH=arm
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
		cp bootloader/at91bootstrap-3.7-acqua-256m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
	elif [ $BOARD -eq $ACQUA512 ]; then
		cp bootloader/at91bootstrap-3.7-acqua-512m/binaries/sama5d3_acqua-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
	elif [ $BOARD -eq $ARIAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-aria-128m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
	elif [ $BOARD -eq $ARIAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-aria-256m/binaries/at91sam9x5_aria-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
	elif [ $BOARD -eq $ARIETTAG25128 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-128m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
	elif [ $BOARD -eq $ARIETTAG25256 ]; then
		cp bootloader/at91bootstrap-3.7-arietta-256m/binaries/at91sam9x5_arietta-sdcardboot-linux-zimage-dt-3.7.bin /media/$USER/boot/boot.bin
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
	echo "Copy the bootloader on the micro sd"
	echo
	echo
	sleep 1
	if [ $KERNEL -eq $K2_6_38 ] || [ $KERNEL -eq $K2_6_39 ] || [ $KERNEL -eq $K3_10 ] || [ $KERNEL -eq $K3_16_1 ] || [ $KERNEL -eq $K3_18_14 ]; then
		sudo rsync -axHAX --progress rootfs/multistrap_debian_wheezy/target-rootfs/ /media/$USER/rootfs/
	else
		#newer kernel
		sudo rsync -axHAX --progress rootfs/multistrap_debian_jessie/target-rootfs/ /media/$USER/rootfs/
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
		cp arch/arm/boot/dts/acme-acqua.dtb /media/$USER/boot/at91-sama5d3_acqua.dtb
		cp arch/arm/boot/dts/acme-acqua.dts /media/$USER/boot/at91-sama5d3_acqua.dts
	elif [ $BOARD -eq $ARIAG25128 ] || [ $BOARD -eq $ARIAG25256 ]; then
		cp arch/arm/boot/dts/acme-aria.dtb /media/$USER/boot/at91-ariag25.dtb
		cp arch/arm/boot/dts/acme-aria.dts /media/$USER/boot/at91-ariag25.dts
	elif [ $BOARD -eq $ARIETTAG25128 ] || [ $BOARD -eq $ARIETTAG25256 ]; then
		cp arch/arm/boot/dts/acme-arietta.dtb /media/$USER/boot/acme-arietta.dtb
		cp arch/arm/boot/dts/acme-arietta.dts /media/$USER/boot/acme-arietta.dts
	fi

	cp arch/arm/boot/zImage /media/$USER/boot
	sudo rsync -avc modules/lib/. /media/$USER/rootfs/lib/.
	#exit from this kernel
	cd ..
	#exit from kernel folder
	cd ..
}

function umountmemory {
	sync
	sudo umount /media/$USER/boot
	sudo umount /media/$USER/rootfs
	sudo umount /media/$USER/data
}

function bootloadernotpresent () {
	echo
	echo "This kernel is not present on disk"
	echo
	exit
}

#validate bootloader by match with kernel & board
function validateb () {
	if [ $BOARD -eq $ACQUA256 ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-acqua-256m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $ACQUA512 ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-acqua-512m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIAG25128 ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-aria-128m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIAG25256 ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-aria-256m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIETTAG25128 ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-arietta-128m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $ARIETTAG25256 ];  then
		if [ ! -f  bootloader/at91bootstrap-3.7-arietta-256m ]; then
			boootloadernotpresent
		fi
	elif [ $BOARD -eq $FOX ]; then
		if [ ! -f  bootloader/at91bootstrap-3.7-acqua-512m ]; then
			boootloadernotpresent
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
theend

