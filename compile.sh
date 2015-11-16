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
read BOARD
echo
}

#option for $KERNEL
readonly K4_2_6=1
readonly K4_1_11=2
readonly K3_18_14=3
readonly K3_16_1=4
readonly K3_10=5
readonly K2_6_39=6
readonly K2_6_38=7

function menukernel {
echo
echo
echo "Which kernel version do you want ?"
echo
if [ $BOARD -eq $ACQUA256 ] || [ $BOARD -eq $ACQUA512 ]; then
	echo "1: 4.2.6"
	echo "2: 4.1.11"
	echo "5: 3.10"
	read KERNEL
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
	read KERNEL
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
	read KERNEL
	if [ $KERNEL -eq 1 ] || [ $KERNEL -eq 2 ] || [ $KERNEL -eq 3 ] || [ $KERNEL -eq 4 ]; then
		echo "Ok"
	else
		wrong
	fi

elif [ $BOARD -eq $FOX ]; then
	echo "7: 2.6.38"
	read KERNEL
	if [ $KERNEL -eq 7 ]; then
		echo "Ok"
	else
		wrong
	fi
else
	wrong
fi
echo
}


function compilebootloader {
echo
echo
echo "Compilation of bootloader"
echo
echo
sleep 1

if [ $BOARD -eq $ACQUA256 ]; then
	echo
	cd at91bootstrap-3.7-acqua-256m
	make acqua-256m_defconfig
elif [ $BOARD -eq $ACQUA512 ]; then
	echo
	cd at91bootstrap-3.7-acqua-512m
	make acqua-512m_defconfig
elif [ $BOARD -eq $ARIAG25128 ]; then
	echo
	cd at91bootstrap-3.7-aria-128m
	make aria-128m_defconfig
elif [ $BOARD -eq $ARIAG25256 ]; then
	echo
	cd at91bootstrap-3.7-aria-256m
	make aria-256m_defconfig
elif [ $BOARD -eq $ARIETTAG25128 ]; then
	echo
	cd at91bootstrap-3.7-arietta-128m
	make arietta-128m_defconfig
elif [ $BOARD -eq $ARIETTAG25256 ]; then
	echo
	cd at91bootstrap-3.7-arietta-256m
	make arietta-256m_defconfig
elif [ $BOARD -eq $FOX ]; then
	echo

else
	wrong
fi

if [ $BOARD -eq $ARIAG25128 ] && [ $KERNEL -eq $K2_6_39 ]; then
	# http://www.acmesystems.it/ariaboot
	echo
elif [ $BOARD -eq $ARIAG25256 ] && [ $KERNEL -eq $K2_6_39 ]; then
	# http://www.acmesystems.it/ariaboot
	echo
elif [ $BOARD -eq $FOX ] && [ $KERNEL -eq $K2_6_38 ]; then
	# http://www.acmesystems.it/acmeboot
	echo
else
	#for all other
	make menuconfig
	make CROSS_COMPILE=arm-linux-gnueabi-
fi
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
	echo "Compilation of the kernel"
	echo
	echo
	sleep 1

	if   [ $KERNEL -eq $K4_2_6 ]; then
		cd kernel/linux-4.2.6
	elif [ $KERNEL -eq $K4_1_11 ]; then
		cd kernel/linux-4.1.11
	elif [ $KERNEL -eq $K3_18_14 ]; then
		cd kernel/linux-3.18.14
	elif [ $KERNEL -eq $K3_16_1 ]; then
		cd kernel/linux-3.16.1
	elif [ $KERNEL -eq $K3_10 ]; then
		cd kernel/linux-3.10
	elif [ $KERNEL -eq $K2_6_39 ]; then
		cd kernel/linux-2.6.39
	elif [ $KERNEL -eq $K2_6_38 ]; then
		cd kernel/linux-2.6.38
	else
		wrong
	fi

	make ARCH=arm menuconfig

	if [ $BOARD -eq $FOX ]; then
		make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- uImage
	else
		make -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- zImage
	fi

	make modules -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
	make modules_install INSTALL_MOD_PATH=./modules ARCH=arm
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
	echo "Copy of bootloader on micro sd"
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
		echo "to be do"
	else
		wrong
	fi
}

function copyrootfs {
	echo
	echo
	echo "Copy of bootloader on micro sd"
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
	echo "Copy of kernel on micor sd"
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


#
# P R O G R A M
#
menuboard
menukernel
compilebootloader
compilekernel
copyfiles
umountmemory
theend

