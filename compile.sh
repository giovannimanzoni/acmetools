#!/bin/sh
#
echo "scegli la board Acme per la prima configurazione"
echo "1: Acqua A5 256M"
echo "2: Acqua A5 512M"
echo "3: Aria G25 128M"
echo "4: Aria G25 256M"
echo "5: Arietta G25 128M"
echo "6: Arietta G25 256M"
read

cd at91bootstrap-3.7-acqua-256m
make acqua-256m_defconfig
#
cd at91bootstrap-3.7-acqua-512m
make acqua-512m_defconfig
#
cd at91bootstrap-3.7-aria-128m
make aria-128m_defconfig
#
cd at91bootstrap-3.7-aria-256m
make aria-256m_defconfig
#
cd at91bootstrap-3.7-arietta-128m
make arietta-128m_defconfig
#
cd at91bootstrap-3.7-arietta-256m
make arietta-256m_defconfig


make CROSS_COMPILE=arm-linux-gnueabi-
cd ..

