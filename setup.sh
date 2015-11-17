#!/bin/bash
#
# This file for compile the system and prepare all files for the micro sd.
# The script will ask you what is your target (Acme Systems board name)
# and it will propose what you can choose (as kernel version)
# and it will use or ask the right rootfs that is needed (Jessie / Wheezy)
#
#
# Licensed under GPLv2 or later.
# Creative Commons License
# This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
# Author: Giovanni Manzoni (commerciale@hardelettrosoft.com)
# Based on work of : Sergio Tanzilli (sergio@tanzilli.com)
##

LOG_FILE='setup.log'
POINTER= #function return values
function addtogit {
git init
git add .
git commit -m "Linux vanilla"
git branch acme
git checkout acme
}

function rootfscommon {
ARCH=$1
CONF=$2
local YN=''
until [[ $YN =~ ^(y|Y)$   ]]; do
	echo
	echo
	echo "NOW PAY ATENTION IF APT-GET FAIL OR NOT TO DOWNLOAD SOME PACKAGE"
	echo "If fail, the rootfs folder is not complete and construction of rootfs can not be complete"
	echo "THE SCRIPT NEED REPEAT THIS STEP. Please press any key"
	echo
	echo
	read -n 1 KEY

	sudo multistrap -a $ARCH -f $CONF
	sudo cp /usr/bin/qemu-arm-static target-rootfs/usr/bin
	sudo mount -o bind /dev/ target-rootfs/dev/
	echo
	beep
	echo
	echo
	echo ">>>> Does the apt-get step end without problem ? [y/n/Y/N] <<<<"
	echo
	read_yn
	YN=$POINTER
	if [[ $YN  =~ ^(n|N)$ ]]; then
		echo "Setup of rootfs with multistrap failed" >> ../../../$LOG_FILE
		sudo umount target-rootfs/dev/
		echo
		echo "So, this step will be repeat. Downloaded files will be deleted. Press any key"
		read -n 1 KEY
		sudo rm -rf target-rootfs
	else
		echo "Setup of rootfs with multistrap Pass" >> ../../../$LOG_FILE
	fi
done
echo
echo "Choose 'No' when ask configuring dash. Press any key"
echo
read -n 1
sudo LC_ALL=C LANGUAGE=C LANG=C chroot target-rootfs dpkg --configure -a
}

function rootfsend {
echo
echo ">>>> Insert root password FOR TARGET BOARD <<<<"
echo
sudo chroot target-rootfs passwd
# sudo rm target-rootfs/usr/bin/qemu-arm-static
sudo umount target-rootfs/dev/
}

function menu {
echo
echo
echo "First setup"
echo
echo "1: Select Acme Systems boards to setup for"
echo "2: Validate Host requirement"
echo "3: Setup packages from apt-get"
echo "4: Setup kernel"
echo "5: Setup rootfs"
echo "6: Setup bootloader" #depend of kernel version
echo
echo "log saved in setup.log"
echo
echo "P R E S S     A N Y     K E Y     T O     S T A R T"
echo
read -n 1 KEY
echo
touch $LOG_FILE
echo "==============================" >> $LOG_FILE
echo "$(date)   | S T A R T" >> $LOG_FILE
}

function read_yn {
	local YN=''
	until [[ $YN =~ ^(y|n|Y|N)$ ]];	do
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

SETUPFORACQUA=0
SETUPFORARIA=0
SETUPFORARIETTA=0
SETUPFORFOX=0
function selectacmeboards {
	echo
	echo
	echo "1/6: Please select Acme boards"
	echo "-------------------------------------"
	echo
	echo "Do you want configure Host for Acqua A5? [y/n/Y/N]"
	read_yn; SETUPFORACQUA=$POINTER
	echo "$(date)   | Setup for Acqua A5 -> $SETUPFORACQUA" >> $LOG_FILE
	echo
	echo "Do you want configure Host for Aria G25? [y/n/Y/N]"
	read_yn; SETUPFORARIA=$POINTER
	echo "$(date)   | Setup for Aria G25 -> $SETUPFORARIA" >> $LOG_FILE
	echo
	echo "Do you want configure Host for Arietta G25? [y/n/Y/N]"
	read_yn; SETUPFORARIETTA=$POINTER
	echo "$(date)   | Setup for Arietta G25 -> $SETUPFORARIETTA" >> $LOG_FILE
	echo
	echo "Do you want configure Host for Fox G20? [y/n/Y/N]"
	read_yn; SETUPFORFOX=$POINTER
	echo "$(date)   | Setup for Fox G20 -> $SETUPFORFOX" >> $LOG_FILE
	echo
	if [[ $SETUPFORACQUA =~ ^(n|N)$ ]] && [[ $SETUPFORARIA =~ ^(n|N)$ ]] && [[ $SETUPFORARIETTA =~ ^(n|N)$ ]] && [[ $SETUPFORFOX =~ ^(n|N)$ ]]; then
		echo "You have not chosen any board. Exit"
		echo
		exit
	fi
}

function validate {
#only ubuntu - to be do
#cat /etc/issue
echo
echo
echo "2/6: Validate Host requirement"
echo "-------------------------------------"
echo "To be do"
echo

#validate - to be do
}



function setuppackages {
echo
echo
echo "3/6: Setup package from apt-get"
echo "-------------------------------------"
echo
echo
echo "If apt-get fail, your repositories are old !! you have to setup old-releases repo, look at http://wiki.ubuntu-it.org/Repository/SourcesList/EOL"
echo
echo "Press any key to next step"
echo
read -n 1 KEY
echo "$(date)   | Setup package" >> $LOG_FILE
sudo apt-get update
sudo apt-get install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi libncurses5-dev beep gparted git multistrap qemu qemu-user-static binfmt-support dpkg-cross

if  [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	sudo apt-get install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
fi
if [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]] || [[ $SETUPFORFOX =~ ^(y|Y)$ ]]; then
	sudo apt-get install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi
fi
if [[ $SETUPFORFOX =~ ^(y|Y)$ ]]; then
	sudo apt-get install python python-serial
fi
}

readonly KERNEL_SETUP_LAST=1
readonly KERNEL_SETUP_ALL=2
readonly KERNEL_SETUP_ASK=3

function asksetup4_2_6 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 4.2.6 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for (kernel_setup = ask & answer =y) or (all) or (last)
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -ne $KERNEL_SETUP_ASK ]; then
		setup4_2_6
	fi
}

function asksetup4_1_11 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 4.1.11 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup4_1_11
	fi
}

function asksetup3_18_14 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 3.18.14 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup3_18_14
	fi
}

function asksetup3_16_1 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 3.16.1 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup3_16_1
	fi
}

function asksetup3_14_23 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 3.14.23 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup3_14_23
	fi
}

function asksetup3_10 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 3.10 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup3_10
	fi
}

NEED_ARIABOOT=0
function asksetup2_6_39 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 2.6.39 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		NEED_ARIABOOT=1
		setup2_6_39
	fi
}

function asksetup2_6_38 {
	local KERNEL_YN=''
	if [ $KERNEL_SETUP -eq $KERNEL_SETUP_ASK ]; then
		echo "Do you want configure Kernel 2.6.38 ? [y/n/Y/N]"
		read_yn; KERNEL_YN=$POINTER
	fi
	#check: valid for kernel_setup = ask (=y) or all
	if [[ $KERNEL_YN =~ ^(y|Y)$ ]] || [ $KERNEL_SETUP -eq $KERNEL_SETUP_ALL ]; then
		setup2_6_38
	fi
}

function setupkernel {
echo
echo
echo "4/6: Setup kernel"
echo "-------------------------------------"
echo
echo "$(date)   | Setup kernel" >> $LOG_FILE
echo "In compatibility with your selected boards, which version of kernel you want ?"
echo "1: Only last kernel"
echo "2: All kernel tested by Acme Systems"
echo "3: Ask 1-by-1 if download and configure or skip"
read -n 1 KERNEL_SETUP
echo
cd kernel

if  [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]] || [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	asksetup4_2_6
fi
if  [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]] || [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	asksetup4_1_11
fi
if  [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
	asksetup3_18_14
fi
if  [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
	asksetup3_16_1
fi
if [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
	asksetup3_14_23
fi
if [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	asksetup3_10
fi
if [[ $SETUPFORARIA =~ ^(y|Y)$ ]]; then
	asksetup2_6_39
fi
if [[ $SETUPFORFOX =~ ^(y|Y)$ ]]; then
	asksetup2_6_38
fi
#exit from kernel folder
cd ..
}

function setup4_2_6 {
#4.2.6
echo
echo
echo "S E T U P   K E R N E L   4 . 2 . 6"
echo
echo
if [ ! -d linux-4.2.6 ]; then
	echo "$(date)   | Setup kernel 4.2.6" >> ../$LOG_FILE
	if [ ! -f linux-4.2.6.tar.xz ]; then
		wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.6.tar.xz
	fi
	tar xvfJ linux-4.2.6.tar.xz
	cd linux-4.2.6
	addtogit
	wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.2.6.patch
	patch -p1 < linux-4.2.6.patch
	cd ..
else
	echo "Setup kernel 4.2.6 done in the past"
	echo
	echo "$(date)   | Setup kernel 4.2.6 done in the past" >> ../$LOG_FILE
fi
}

function setup4_1_11 {
echo
echo
echo "S E T U P   K E R N E L   4 . 1 . 1 1"
echo
echo
if [ ! -d linux-4.1.11 ]; then
	echo "$(date)   | Setup kernel 4.1.11" >> ../$LOG_FILE
	if [ ! -f linux-4.1.11.tar.xz ]; then
		wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.11.tar.xz
	fi
	tar xvfJ linux-4.1.11.tar.xz
	cd linux-4.1.11
	addtogit
	wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.1.11.patch
	patch -p1 < linux-4.1.11.patch
	cd ..
else
	echo "Setup kernel 4.1.11 done in the past"
	echo
	echo "$(date)   | Setup kernel 4.1.11 done in the past" >> ../$LOG_FILE
fi
}

function setup3_18_14 {
echo
echo
echo "S E T U P   K E R N E L   3 . 1 8 . 1 4"
echo
echo
if [ ! -d linux-3.18.14 ]; then
	echo "$(date)   | Setup kernel 3.18.14" >> ../$LOG_FILE
	if [ ! -f linux-3.18.14.tar.xz ]; then
		wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.14.tar.xz
	fi
	tar xvfJ linux-3.18.14.tar.xz
	cd linux-3.18.14
	addtogit
	wget http://www.acmesystems.it/www/compile_linux_3_18/acme-arietta_defconfig
	wget http://www.acmesystems.it/www/compile_linux_3_18/acme-aria_defconfig
	mv acme-arietta_defconfig arch/arm/configs/
	mv acme-aria_defconfig arch/arm/configs/
	wget http://www.acmesystems.it/www/compile_linux_3_18/acme-arietta.dts
	wget http://www.acmesystems.it/www/compile_linux_3_18/acme-aria.dts
	mv *.dts arch/arm/boot/dts/
	cd ..
else
	echo "Setup kernel 3.18.14 done in the past"
	echo
	echo "$(date)   | Setup kernel 3.18.14 done in the past" >> ../$LOG_FILE
fi
}

function setup3_16_1 {
echo
echo
echo "S E T U P   K E R N E L   3 . 1 6 . 1"
echo
echo
if [ ! -d linux-3.16.1 ]; then
	echo "$(date)   | Setup kernel 3.16.1" >> ../$LOG_FILE
	if [ ! -f linux-3.16.1.tar.xz ]; then
		wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.16.1.tar.xz
	fi
	tar xvfJ linux-3.16.1.tar.xz
	cd linux-3.16.1
	addtogit
	wget http://www.acmesystems.it/www/compile_linux_3_16/acme-arietta_defconfig
	wget http://www.acmesystems.it/www/compile_linux_3_16/acme-aria_defconfig
	mv acme-arietta_defconfig arch/arm/configs/
	mv acme-aria_defconfig arch/arm/configs/
	wget http://www.acmesystems.it/www/compile_linux_3_16/acme-aria.dts
	wget http://www.acmesystems.it/www/compile_linux_3_16/acme-arietta.dts
	mv *.dts arch/arm/boot/dts/
	cd ..
else
	echo "Setup kernel 3.16.1 done in the past"
	echo
	echo "$(date)   | Setup kernel 3.16.1 done in the past" >> ../$LOG_FILE
fi
}

function setup3_14_23 {
echo
echo
echo "S E T U P   K E R N E L   3 . 1 4 . 2 3"
echo
echo
if [ ! -d linux-3.14.23 ]; then
	echo "$(date)   | Setup kernel 3.14.23" >> ../$LOG_FILE
	if [ ! -f linux-3.14.23.tar.xz ]; then
		wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.23.tar.xz
	fi
	tar xvfJ linux-3.14.23.tar.xz
	cd linux-3.14.23
	addtogit
	wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta_defconfig
	mv acme-arietta_defconfig arch/arm/configs/
	wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta.dts
	mv *.dts arch/arm/boot/dts/
	cd ..
else
	echo "Setup kernel 3.14.23 done in the past"
	echo
	echo "$(date)   | Setup kernel 3.14.23 done in the past" >> ../$LOG_FILE
fi
}

function setup3_10 {
echo
echo
echo "S E T U P   K E R N E L   3 . 1 0"
echo
echo
if [ ! -d linux-3.10 ]; then
	echo "$(date)   | Setup kernel 3.10" >> ../$LOG_FILE
	if [ ! -f linux-3.10-at91.zip ]; then
		wget https://github.com/linux4sam/linux-at91/archive/linux-3.10-at91.zip
	fi
	unzip linux-3.10-at91.zip
	mv linux-at91-linux-3.10-at91 linux-3.10-acqua
	cd linux-3.10-acqua
	addtogit
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme.patch
	patch -p1 < acme.patch
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme-acqua_lcd_43.dts
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme-acqua_lcd_50.dts
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme-acqua_lcd_70.dts
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme-acqua_no_lcd.dts
	mv *.dts arch/arm/boot/dts/
	wget http://www.acmesystems.it/www/compile_linux_3_10_acqua/acme-acqua_defconfig
	mv acme-acqua_defconfig arch/arm/configs/
	cd ..
else
	echo "Setup kernel 3.10 done in the past"
	echo
	echo "$(date)   | Setup kernel 3.10 done in the past" >> ../$LOG_FILE
fi
}

function setup2_6_39 {
echo
echo
echo "S E T U P   K E R N E L   2 . 6 . 3 9"
echo
echo
if [ ! -d linux-2.6.39 ]; then
	echo "$(date)   | Setup kernel 2.6.39" >> ../$LOG_FILE
	if [ ! -f linux-2.6.39.tar.bz2 ]; then
		wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.39.tar.bz2
	fi
	tar -xvjf linux-2.6.39.tar.bz2
	cd linux-2.6.39
	addtogit
	wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.patch.tar.gz
	tar -xvzf ariag25.patch.tar.gz
	patch -p1 < ariag25.patch
	wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.config.tar.gz
	tar -xvzf ariag25.config.tar.gz
	cd ..
else
	echo "Setup kernel 2.6.39 done in the past"
	echo
	echo "$(date)   | Setup kernel 2.6.39 done in the past" >> ../$LOG_FILE
fi
}

function setup2_6_38 {
echo
echo
echo "S E T U P   K E R N E L   2 . 6 . 3 8"
echo
echo
if [ ! -d foxg20-linux-2.6.38 ]; then
	echo "$(date)   | Setup kernel 2.6.38" >> ../$LOG_FILE
	git clone git://github.com/tanzilli/foxg20-linux-2.6.38.git
	cd foxg20-linux-2.6.38
	addtogit
	make foxg20_defconfig
	cd ..
else
	echo "Setup kernel 2.6.38 done in the past"
	echo
	echo "$(date)   | Setup kernel 2.6.38 done in the past" >> ../$LOG_FILE
fi
}

function setupwheezyaria {
echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A R I A   G 2 5"
echo
echo
if [ ! -d aria ]; then
	echo "$(date)   | Setup rootfs Wheezy for Aria G25" >> ../../$LOG_FILE
	mkdir aria
	cd aria
	wget http://www.acmesystems.it/www/debian_wheezy/multistrap_aria.conf
	rootfscommon armel multistrap_aria.conf
	wget http://www.acmesystems.it/www/debian_wheezy/aria.sh
	chmod +x aria.sh
	sudo ./aria.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Wheezy for Aria G25 done in the past"
	echo
	echo "$(date)   | Setup rootfs Wheezy for Aria G25 done in the past" >> ../../$LOG_FILE
fi
}

function setupwheezyarietta {
echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A R I E T T A   G 2 5"
echo
echo
if [ ! -d arietta]; then
	echo "$(date)   | Setup rootfs Wheezy for Arietta G25" >> ../../$LOG_FILE
	mkdir arietta
	cd arietta
	wget http://www.acmesystems.it/www/debian_wheezy/multistrap_arietta.conf
	rootfscommon armel multistrap_arietta.conf
	wget http://www.acmesystems.it/www/debian_wheezy/arietta.sh
	chmod +x arietta.sh
	sudo ./arietta.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Wheezy for Arietta G25 done in the past"
	echo
	echo "$(date)   | Setup rootfs Wheezy for Arrietta G25 done in the past" >> ../../$LOG_FILE
fi
}

function setupforacqua {
echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A C Q U A"
echo
echo
if [ ! -d acqua ]; then
	echo "$(date)   | Setup rootfs Wheezy for Acqua" >> ../../$LOG_FILE
	mkdir acqua
	cd acqua
	wget http://www.acmesystems.it/www/debian_wheezy/multistrap_acqua.conf
	rootfscommon armhf multistrap_acqua.conf
	wget http://www.acmesystems.it/www/debian_wheezy/acqua.sh
	chmod +x acqua.sh
	sudo ./acqua.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Wheezy for Acqua done in the past"
	echo
	echo "$(date)   | Setup rootfs Wheezy for Acqua done in the past" >> ../../$LOG_FILE
fi
}

function setuprootfswheezy {
echo "$(date)   | Setup rootfs Wheezy" >> $LOG_FILE
cd rootfs
echo "$(date)   | Setup rootfs Wheezy" >> ../$LOG_FILE
if [ ! -f multistrap_debian_wheezy ]; then
	mkdir multistrap_debian_wheezy
fi
cd multistrap_debian_wheezy
if [[ $SETUPFORARIA =~ ^(y|Y)$ ]]; then
	setupwheezyaria
fi
if [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
	setupwheezyarietta
fi
if [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	setupwheezyacqua
fi
#foxg20 -> missing multistrap for fox from http://www.acmesystems.it/debian_wheezy at 13/11/2015
#if [ $SETUPFORFOX =~ ^(y|Y)$ ]; then
#	setupwheezyaria
#fi

#exit from multistrap Wheezy
cd ..
#exit from rootfs
cd ..
}

function setupjessiearia {
echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A R I A   G 2 5"
echo
echo
if [ ! -d aria ]; then
	echo "$(date)   | Setup rootfs Jessie for Aria G25" >> ../../$LOG_FILE
	mkdir aria
	cd aria
	wget http://www.acmesystems.it/www/debian_jessie/multistrap_aria.conf
	rootfscommon armel multistrap_aria.conf
	wget http://www.acmesystems.it/www/debian_jessie/aria.sh
	chmod +x aria.sh
	sudo ./aria.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Jessie for Aria G25 done in the past"
	echo
	echo "$(date)   | Setup rootfs Jessie for Aria G25 done in the past" >> ../../$LOG_FILE
fi
}

function setupjessiearietta {
echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A R I E T T A   G 2 5"
echo
echo
if [ ! -d arietta ]; then
	echo "$(date)   | Setup rootfs Jessie for Arietta G25" >> ../../$LOG_FILE
	mkdir arietta
	cd arietta
	wget http://www.acmesystems.it/www/debian_jessie/multistrap_arietta.conf
	rootfscommon armel multistrap_arietta.conf
	wget http://www.acmesystems.it/www/debian_jessie/arietta.sh
	chmod +x arietta.sh
	sudo ./arietta.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Jessie for Arietta G25 done in the past"
	echo
	echo "$(date)   | Setup rootfs Jessie for Arietta G25 done in the past" >> ../../$LOG_FILE
fi
}

function setupjessieacqua {
echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A C Q U A"
echo
echo
if [ ! -d acqua ]; then
	echo "$(date)   | Setup rootfs Jessie for Acqua" >> ../../$LOG_FILE
	mkdir acqua
	cd acqua
	wget http://www.acmesystems.it/www/debian_jessie/multistrap_acqua.conf
	rootfscommon armel multistrap_acqua.conf
	wget http://www.acmesystems.it/www/debian_jessie/acqua.sh
	chmod +x acqua.sh
	sudo ./acqua.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Jessie for Acqua done in the past"
	echo
	echo "$(date)   | Setup rootfs Jessie for Acqua done in the past" >> ../../$LOG_FILE
fi
}

function setupjessiefox {
echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   F O X   G 2 0"
echo
echo
if [ ! -d fox ]; then
	echo "$(date)   | Setup rootfs Jessie for FoxG20" >> ../../$LOG_FILE
	mkdir fox
	cd fox
	wget http://www.acmesystems.it/www/debian_jessie/multistrap_fox.conf
	rootfscommon armel multistrap_fox.conf
	wget http://www.acmesystems.it/www/debian_jessie/fox.sh
	chmod +x fox.sh
	sudo ./fox.sh
	rootfsend
	cd ..
else
	echo "Setup rootfs Jessie for Fox G20 done in the past"
	echo
	echo "$(date)   | Setup rootfs Jessie for Fox G20 done in the past" >> ../../$LOG_FILE
fi
}

function setuprootfsjessie {
echo "$(date)   | Setup rootfs Jessie" >> ../$LOG_FILE
cd rootfs
if [ ! -d multistrap_debian_jessie ]; then
	mkdir multistrap_debian_jessie
fi
cd multistrap_debian_jessie
if [[ $SETUPFORARIA =~ ^(y|Y)$ ]]; then
	setupjessiearia
fi
if [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
	setupjessiearietta
fi
if [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	setupjessieacqua
fi
if [[ $SETUPFORFOX =~ ^(y|Y)$ ]]; then
	setupjessiefox
fi

#exit from multistrap Jessie
cd ..
#exit from rootfs
cd ..
}

function setupbootloader {
echo
echo
echo "6/6: Setup bootloader"
echo "-------------------------------------"
echo
echo
echo "$(date)   | Setup bootloader" >> $LOG_FILE
cd bootloader
if [[ $SETUPFORARIA =~ ^(y|Y)$ ]] || [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]] || [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
	#only if ubuntu <=14
	# cat /etc/issue - to be do
	echo "$(date)   | Setup at91bootstrap" >> ../$LOG_FILE
	if [ ! -f v3.7.zip ]; then
		wget https://github.com/linux4sam/at91bootstrap/archive/v3.7.zip
	fi
	if [ ! -d at91bootstrap-3.7 ]; then
		unzip v3.7.zip
	fi
	if [ ! -f at91bootstrap-3.7/.config ]; then
		cd at91bootstrap-3.7
		if [ ! -f at91bootstrap-3.7.patch ]; then
			wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/at91bootstrap-3.7.patch
		fi
		patch -p1 <  at91bootstrap-3.7.patch
		#exit from at91bootstrap
		cd ..
	fi
	if [[ $SETUPFORARIA =~ ^(y|Y)$ ]]; then
		if [ ! -d at91bootstrap-3.7-aria-128m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-aria-128m
		fi
		if [ ! -d at91bootstrap-3.7-aria-256m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-aria-256m
		fi
	fi
	if [[ $SETUPFORARIETTA =~ ^(y|Y)$ ]]; then
		if [ ! -d at91bootstrap-3.7-arietta-128m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-arietta-128m
		fi
		if [ ! -d at91bootstrap-3.7-arietta-256m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-arietta-256m
		fi
	fi
	if [[ $SETUPFORACQUA =~ ^(y|Y)$ ]]; then
		if [ ! -d at91bootstrap-3.7-acqua-256m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-acqua-256m
		fi
		if [ ! -d at91bootstrap-3.7-acqua-512m ]; then
			cp -R at91bootstrap-3.7 at91bootstrap-3.7-acqua-512m
		fi
	fi
	rm -rf at91bootstrap-3.7
fi
if [[ $SETUPFORFOX =~ ^(y|Y)$ ]]; then
	if [ ! -d acmeboot ]; then
		echo "$(date)   | Setup acmeboot" >> $LOG_FILE
		mkdir acmeboot
		cd acmeboot
		wget http://terzo.acmesystems.it/download/acmeboot/pizzica.py
		wget http://terzo.acmesystems.it/download/acmeboot/xmodem.py
		wget http://www.acmesystems.it/www/acmeboot/acmeboot_dataflash_1.22.bin
		wget http://www.acmesystems.it/www/acmeboot/acmeboot_serialflash_1.22.bin
		wget http://terzo.acmesystems.it/download/acmeboot/macaddress.txt
		wget http://www.acmesystems.it/www/troubleshootings/foxg20-script.bin
		touch cmdline.txt
		echo "mem=64M console=ttyS0,115200 noinitrd root=/dev/mmcblk0p2 rw rootwait init=/sbin/init" >> cmdline.txt
		touch  machtype.txt
		echo "3129" >  machtype.txt
		#exif from acmeoboot
		cd ..
	fi
fi
if [ $NEED_ARIABOOT -eq 1 ]; then
	if [ ! -d AriBoot ]; then
		echo "$(date)   | Setup ariaboot" >> $LOG_FILE
		git clone git://github.com/tanzilli/AriaBoot.git
		cd AriaBoot
		make
		#exit from ariaboot
		cd ..
	fi
fi
#exit from bootloader
cd ..
}

function theend {
echo "$(date)   | The End" >> $LOG_FILE
echo
echo "The End"
echo
}

menu
selectacmeboards
validate
setuppackages
if [ ! -d bootloader ]; then
	mkdir bootloader
fi
if [ ! -d kernel ]; then
	mkdir kernel
fi
if [ ! -d rootfs ]; then
	mkdir rootfs
fi
setupkernel
echo
echo
echo "5/6: Setup rootfs"
echo "-------------------------------------"
echo
echo
if [ $KERNEL_SETUP -eq $KERNEL_SETUP_LAST ]; then
	setuprootfsjessie #last
else
#to be do for match working kernel & rootfs
	setuprootfsjessie #last
	setuprootfswheezy #old
fi
setupbootloader
theend

