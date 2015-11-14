#!/bin/bash
#
# This file prepare a complete setup on a pc for all Acme Systems products
#
# Copyright (C) 2015 Giovanni Manzoni <commerciale@hardelettrosoft.com>
#
# Licensed under GPLv2 or later.
#

LOG_FILE='setup.log'

function addtogit {
git init
git add .
git commit -m "Linux vanilla"
git branch acme
git checkout acme
}

function rootfscommon {
sudo cp /usr/bin/qemu-arm-static target-rootfs/usr/bin
sudo mount -o bind /dev/ target-rootfs/dev/
echo
beep
echo
echo
echo "PAY ATENTION TO THE PREVIOUS LINE IF APT-GET FAIL OR NOT TO DOWNLOAD SOME PACKAGE "
echo "If yes, the rootfs folder is not complete and costruction of rootfs can not continue ! ! ! !"
echo
echo
echo "Choose 'No' when ask configuring dash. press Enter"
echo
read
sudo LC_ALL=C LANGUAGE=C LANG=C chroot target-rootfs dpkg --configure -a
}

function rootfsend {
echo
echo ">>>> Insert root password FOR TARGET BOARD<<<<"
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
echo "1: Validate Host requirement"
echo "2: Setup packages from apt-get"
echo "3: Setup at91bootstrap"
echo "4: Setup rootfs"
echo "5: Setup kernel"
echo
echo "log saved in setup.log"
echo
echo "P R E S S     E N T E R     T O     S T A R T"
echo
read KEY
}

function validate {
#only ubuntu - to be do
#cat /etc/issue
echo
echo
echo "1/5: Validate Host requirement"
echo "-------------------------------------"
echo "To be do"
echo
touch $LOG_FILE
echo "==============================" >> $LOG_FILE
echo "S T A R T" >> $LOG_FILE
NOW=$(date)
echo "$NOW" >> $LOG_FILE

#validate - to be do
}

function setuppackages {
# setup package
echo
echo
echo "2/5: Setup package from apt-get"
echo "-------------------------------------"
echo
echo
echo "If apt-get fail, your repositories are old !! you have to setup old-releases repo, look at http://wiki.ubuntu-it.org/Repository/SourcesList/EOL"
echo
echo "Press Enter"
echo
read KEY
echo "Setup package" >> $LOG_FILE
sudo apt-get update
sudo apt-get install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi libncurses5-dev gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf gparted git multistrap qemu qemu-user-static binfmt-support dpkg-cross beep
}

function setupbootloader {
#bootloader
#only if ubuntu <=14
# cat /etc/issue - to be do
echo
echo
echo "3/5: Setup bootloader"
echo "-------------------------------------"
echo
echo
echo "Setup bootloader" >> $LOG_FILE
mkdir bootloader
cd bootloader
#at91bootsrap
wget https://github.com/linux4sam/at91bootstrap/archive/v3.7.zip
unzip v3.7.zip
cd at91bootstrap-3.7
wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/at91bootstrap-3.7.patch
patch -p1 <  at91bootstrap-3.7.patch
cd ..
cp -R at91bootstrap-3.7 at91bootstrap-3.7-acqua-256m
cp -R at91bootstrap-3.7 at91bootstrap-3.7-acqua-512m
cp -R at91bootstrap-3.7 at91bootstrap-3.7-aria-128m
cp -R at91bootstrap-3.7 at91bootstrap-3.7-aria-256m
cp -R at91bootstrap-3.7 at91bootstrap-3.7-arietta-128m
mv    at91bootstrap-3.7 at91bootstrap-3.7-arietta-256m
}

function setupkernel {
#kernel
cd ..
echo
echo
echo "4/5: Setup kernel"
echo "-------------------------------------"
echo
echo
echo "Setup kernel" >> $LOG_FILE
cd kernel
#4.2.6
echo
echo
echo "S E T U P   K E R N E L   4 . 2 . 6"
echo
echo
echo "Setup kernel 4.2.6" >> ../$LOG_FILE
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.6.tar.xz
tar xvfJ linux-4.2.6.tar.xz
cd linux-4.2.6
addtogit
wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.2.6.patch
patch -p1 < linux-4.2.6.patch
cd ..
#4.1.11
echo
echo
echo "S E T U P   K E R N E L   4 . 1 . 1 1"
echo
echo
echo "Setup kernel 4.1.11" >> ../$LOG_FILE
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.11.tar.xz
tar xvfJ linux-4.1.11.tar.xz
cd linux-4.1.11
addtogit
wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.1.11.patch
patch -p1 < linux-4.1.11.patch
cd ..
#3.18.11
echo
echo
echo "S E T U P   K E R N E L   3 . 1 8 . 1 4"
echo
echo
echo "Setup kernel 3.18.14" >> ../$LOG_FILE
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.14.tar.xz
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
#3.16.1
echo
echo
echo "S E T U P   K E R N E L   3 . 1 6 . 1"
echo
echo
echo "Setup kernel 3.16.1" >> ../$LOG_FILE
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.16.1.tar.xz
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
#3.14.23
echo
echo
echo "S E T U P   K E R N E L   3 . 1 4 . 2 3"
echo
echo
echo "Setup kernel 3.14.23" >> ../$LOG_FILE
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.23.tar.xz
tar xvfJ linux-3.14.23.tar.xz
cd linux-3.14.23
addtogit
wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta_defconfig
mv acme-arietta_defconfig arch/arm/configs/
wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta.dts
mv *.dts arch/arm/boot/dts/
cd ..
#3.10
echo
echo
echo "S E T U P   K E R N E L   3 . 1 0"
echo
echo
echo "Setup kernel 3.10" >> ../$LOG_FILE
wget https://github.com/linux4sam/linux-at91/archive/linux-3.10-at91.zip
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
#2.6.39
echo
echo
echo "S E T U P   K E R N E L   2 . 6 . 3 9"
echo
echo
echo "Setup kernel 2.6.39" >> ../$LOG_FILE
wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.39.tar.bz2
tar -xvjf linux-2.6.39.tar.bz2
cd linux-2.6.39
addtogit
wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.patch.tar.gz
tar -xvzf ariag25.patch.tar.gz
patch -p1 < ariag25.patch
wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.config.tar.gz
tar -xvzf ariag25.config.tar.gz
cd ..
#2.6.38
echo
echo
echo "S E T U P   K E R N E L   2 . 6 . 3 8"
echo
echo
echo "Setup kernel 2.6.38" >> ../$LOG_FILE
git clone git://github.com/tanzilli/foxg20-linux-2.6.38.git
cd foxg20-linux-2.6.38
addtogit
make foxg20_defconfig
cd ..
# exit from rootfs folder
cd ..
}

function setuprootfswheezy {
echo "Setup rootfs Wheezy" >> $LOG_FILE
cd rootfs
echo "Setup rootfs Wheezy" >> ../$LOG_FILE
mkdir multistrap_debian_wheezy
cd multistrap_debian_wheezy

echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A R I A   G 2 5"
echo
echo
echo "Setup rootfs Wheezy for AriaG25" >> ../../$LOG_FILE
mkdir aria
cd aria
wget http://www.acmesystems.it/www/debian_wheezy/multistrap_aria.conf
sudo multistrap -a armel -f multistrap_aria.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_wheezy/aria.sh
chmod +x aria.sh
sudo ./aria.sh
rootfsend
cd ..

echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A R I E T T A   G 2 5"
echo
echo
echo "Setup rootfs Wheezy for AriettaG25" >> ../../$LOG_FILE
mkdir arietta
cd arietta
wget http://www.acmesystems.it/www/debian_wheezy/multistrap_arietta.conf
sudo multistrap -a armel -f multistrap_arietta.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_wheezy/arietta.sh
chmod +x arietta.sh
sudo ./arietta.sh
rootfsend
cd ..

#foxg20 -> missing multistrap for fox from http://www.acmesystems.it/debian_wheezy at 13/11/2015

echo
echo
echo "S E T U P   W H E E Z Y   R O O T F S   F O R   A C Q U A"
echo
echo
echo "Setup rootfs Wheezy for Acqua" >> ../../$LOG_FILE
mkdir acqua
cd acqua
wget http://www.acmesystems.it/www/debian_wheezy/multistrap_acqua.conf
sudo multistrap -a armhf -f multistrap_acqua.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_wheezy/acqua.sh
chmod +x acqua.sh
sudo ./acqua.sh
rootfsend
cd ..


#exit from multistrap Wheezy
cd ..
#exit from rootfs
cd ..
}

function setuprootfsjessie {
echo "Setup rootfs Jessie" >> ../$LOG_FILE
cd rootfs
mkdir multistrap_debian_jessie
cd multistrap_debian_jessie

echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A C Q U A"
echo
echo
echo "Setup rootfs Jessie for Acqua" >> ../../$LOG_FILE
mkdir acqua
cd acqua
wget http://www.acmesystems.it/www/debian_jessie/multistrap_acqua.conf
sudo multistrap -a armel -f multistrap_acqua.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/acqua.sh
chmod +x acqua.sh
sudo ./acqua.sh
rootfsend
cd ..

echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A R I A   G 2 5"
echo
echo
echo "Setup rootfs Jessie for AriaG25" >> ../../$LOG_FILE
mkdir aria
cd aria
wget http://www.acmesystems.it/www/debian_jessie/multistrap_aria.conf
sudo multistrap -a armel -f multistrap_aria.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/aria.sh
chmod +x aria.sh
sudo ./aria.sh
rootfsend
cd ..

echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   A R I E T T A   G 2 5"
echo
echo
echo "Setup rootfs Jessie for AriettaG25" >> ../../$LOG_FILEecho
mkdir arietta
cd arietta
wget http://www.acmesystems.it/www/debian_jessie/multistrap_arietta.conf
sudo multistrap -a armel -f multistrap_arietta.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/arietta.sh
chmod +x arietta.sh
sudo ./arietta.sh
rootfsend
cd ..

echo
echo
echo "S E T U P   J E S S I E   R O O T F S   F O R   F O X   G 2 0"
echo
echo
echo "Setup rootfs Jessie for FoxG20" >> ../../$LOG_FILE
mkdir fox
cd fox
wget http://www.acmesystems.it/www/debian_jessie/multistrap_fox.conf
sudo multistrap -a armel -f multistrap_fox.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/fox.sh
chmod +x fox.sh
sudo ./fox.sh
rootfsend
cd ..

#exit from multistrap Jessie
cd ..
#exit from rootfs
cd ..
}


function theend {
echo "The End" >> $LOG_FILE
echo
echo "The End"
echo
}

menu
validate
setuppackages
mkdir bootloader
mkdir kernel
mkdir rootfs
setupbootloader
setupkernel
echo
echo
echo "5/5: Setup rootfs"
echo "-------------------------------------"
echo
echo
setuprootfswheezy
setuprootfsjessie
theend

