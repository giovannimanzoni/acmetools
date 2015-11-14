# acmetools
Tools for Acme Systems products

Why this repo
=================
This repo born in order to have a rapid, simple and secure way 
to create a fully functional bootable micro sd 
without always do copy and paste from website, 
without forget to give some command,
without wrong to match kernel version and rootfs version,
without losing hours, 
without #!!#$&@## Arrrrg !! 

This repo born because the problem is about gcc version:
- ubuntu 15 can compile/create rootfs and last kernel but can not compile at91bootstrap, it fail
- ubuntu 15 can compile kernel 3.18.1 but it is not usable on the micro sd !!
- ubuntu 15 can not compile kernel 3.16.1

So the simple way is to use Ubuntu 14 but what about use old Linux distro ? :(
and what about the benefit to compile what can be compiled with the last gcc version ?
and what about forget that some combination of Host os, target rootfs and target kernel do not work together ?? #!!#$&@## Arrrrg !!


The repo is not fully complete yet.


So, let me try

setup.sh <- complete
----------
Use it for download, initial setup, but not compile:
- bootloader
- kernel + dts + patch
- rootfs


clean.sh <- complete
----------
Use it for remove all generated files and folder, used for debug/test 'setup.sh'


compile.sh <- work in progress
----------
Use it for compile the system and prepare all files for the micro sd. 
The script will ask you what is your target (Acme Systems board name)
and it will propose what you can choose (as kernel version)
and it will use the right rootfs that is needed (Jessie / Wheezy)


