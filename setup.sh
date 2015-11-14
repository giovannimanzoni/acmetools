#!/bin/bash
#
# This file prepare a complete setup on a pc for all Acme Systems products
#
# Copyright (C) 2015 Giovanni Manzoni <commerciale@hardelettrosoft.com>
#
# Licensed under GPLv2 or later.
#

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
echo "choose 'No' when ask configuring dash. press Enter"
echo
read
sudo LC_ALL=C LANGUAGE=C LANG=C chroot target-rootfs dpkg --configure -a
}

function rootfsend {
echo
echo "insert root password"
sudo chroot target-rootfs passwd
# sudo rm target-rootfs/usr/bin/qemu-arm-static
}


echo "First setup"
echo
echo "- validate requirement"
echo "- setup package from apt-get"
echo "- setup at91bootstrap"
echo "- setup rootfs"
echo "- setup kernel"
echo
echo "log saved in setup.log"
echo
echo "P R E S S     E N T E R"
echo
read KEY

LOG_FILE='setup.log'

#only ubuntu - to be do
#cat /etc/issue
touch $LOG_FILE
echo "==============================" >> $LOG_FILE
echo "S T A R T" >> $LOG_FILE
NOW=$(date)
echo "$NOW" >> $LOG_FILE

# setup package
echo "setup package from apt-get"
echo
echo "if apt-get fail, your repositories are old !! you have to setup old-releases repo, look at http://wiki.ubuntu-it.org/Repository/SourcesList/EOL"
echo
echo "press Enter"
echo
read KEY
echo "setup package" >> $LOG_FILE
sudo apt-get update
sudo apt-get install libc6-armel-cross libc6-dev-armel-cross binutils-arm-linux-gnueabi libncurses5-dev gcc-arm-linux-gnueabi g++-arm-linux-gnueabi gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf gparted git multistrap qemu qemu-user-static binfmt-support dpkg-cross beep

#bootloader
#only if ubuntu <=14
# cat /etc/issue - to be do
echo "setup bootloader" >> $LOG_FILE
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

#kernel
cd ..
echo "setup kernel" >> $LOG_FILE
mkdir kernel
cd kernel
#4.2.6
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.2.6.tar.xz
tar xvfJ linux-4.2.6.tar.xz
echo "setup kernel 4.2.6" >> ../$LOG_FILE
cd linux-4.2.6
addtogit
wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.2.6.patch
patch -p1 < linux-4.2.6.patch
cd ..
#4.1.11
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.11.tar.xz
tar xvfJ linux-4.1.11.tar.xz
echo "setup kernel 4.1.11" >> ../$LOG_FILE
cd linux-4.1.11
addtogit
wget https://raw.githubusercontent.com/AcmeSystems/acmepatches/master/linux-4.1.11.patch
patch -p1 < linux-4.1.11.patch
cd ..
#3.18.11
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.14.tar.xz
tar xvfJ linux-3.18.14.tar.xz
echo "setup kernel 3.18.14" >> ../$LOG_FILE
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
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.16.1.tar.xz
tar xvfJ linux-3.16.1.tar.xz
echo "setup kernel 3.16.1" >> ../$LOG_FILE
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
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.14.23.tar.xz
tar xvfJ linux-3.14.23.tar.xz
echo "setup kernel 3.14.23" >> ../$LOG_FILE
cd linux-3.14.23
addtogit
wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta_defconfig
mv acme-arietta_defconfig arch/arm/configs/
wget http://www.acmesystems.it/www/compile_linux_3_14/acme-arietta.dts
mv *.dts arch/arm/boot/dts/
cd ..
#3.10
wget https://github.com/linux4sam/linux-at91/archive/linux-3.10-at91.zip
unzip linux-3.10-at91.zip
mv linux-at91-linux-3.10-at91 linux-3.10-acqua
echo "setup kernel 3.10" >> ../$LOG_FILE
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
wget http://www.kernel.org/pub/linux/kernel/v2.6/linux-2.6.39.tar.bz2
tar -xvjf linux-2.6.39.tar.bz2
echo "setup kernel 2.6.39" >> ../$LOG_FILE
cd linux-2.6.39
addtogit
wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.patch.tar.gz
tar -xvzf ariag25.patch.tar.gz
patch -p1 < ariag25.patch
wget http://www.acmesystems.it/www/ariag25_compile_linux_2_6_39/ariag25.config.tar.gz
tar -xvzf ariag25.config.tar.gz
cd ..
#2.6.38
git clone git://github.com/tanzilli/foxg20-linux-2.6.38.git
echo "setup kernel 2.6.38" >> ../$LOG_FILE
cd foxg20-linux-2.6.38
addtogit
make foxg20_defconfig
cd ..

#rootfs
cd ..
echo "setup rootfs" >> $LOG_FILE
mkdir rootfs
cd rootfs
#wheezy
echo "setup rootfs Wheezy" >> ../$LOG_FILE
mkdir multistrap_debian_wheezy
cd multistrap_debian_wheezy

echo "setup rootfs Wheezy for AriaG25" >> ../../$LOG_FILE
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


echo "setup rootfs Wheezy for AriettaG25" >> ../../$LOG_FILE
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

#foxg20 -> missing from http://www.acmesystems.it/debian_wheezy at 13/11/2015

echo "setup rootfs Wheezy for Acqua" >> ../../$LOG_FILE
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

#exit from wheezy
cd ..

#jessie
echo "setup rootfs Jessie" >> ../$LOG_FILE
mkdir multistrap_debian_jessie
cd multistrap_debian_jessie

echo "setup rootfs Jessie for AriaG25" >> ../../$LOG_FILE
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


echo "setup rootfs Jessie for AriettaG25" >> ../../$LOG_FILE
mkdir aria
cd aria
wget http://www.acmesystems.it/www/debian_jessie/multistrap_arietta.conf
sudo multistrap -a armel -f multistrap_arietta.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/arietta.sh
chmod +x arietta.sh
sudo ./arietta.sh
rootfsend
cd ..


echo "setup rootfs Jessie for FoxG20" >> ../../$LOG_FILE
mkdir aria
cd aria
wget http://www.acmesystems.it/www/debian_jessie/multistrap_fox.conf
sudo multistrap -a armel -f multistrap_fox.conf
rootfscommon
wget http://www.acmesystems.it/www/debian_jessie/fox.sh
chmod +x fox.sh
sudo ./fox.sh
rootfsend
cd ..


#exit from rootfs
cd ..
#end
echo "The End" >> $LOG_FILE
echo
echo "The End"
echo

