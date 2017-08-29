#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=10;

##################################################
#              ARCH-CONFIGURATION                #
##################################################

function set_hostname
{
    ERR=0
	# Hostname
	print_pretty_header "Setting Hostname${NC} $HOSTN"
	echo $HOSTN > /etc/hostname || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Hostname error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_keyboard_layout
{
    ERR=0
	# Keybord Layout
	print_pretty_header "Setting Keyboard layout${NC} $KEYBOARD_LAYOUT"
	echo 'KEYMAP='$KEYBOARD_LAYOUT > /etc/vconsole.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Keyboard Layout error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_locale
{
    ERR=0
	# Locale
	print_pretty_header "Setting locale${NC} $LANGUAGE"
	sed -i 's/^#'$LANGUAGE'/'$LANGUAGE/ /etc/locale.gen || ERR=1
	locale-gen 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Locale error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_language
{
    ERR=0
	# Locale locale.conf
	print_pretty_header "Setting language${NC} $LANGUAGE"
	export LANG=$LANGUAGE'.utf-8'
	echo 'LANG='$LANGUAGE'.utf-8' > /etc/locale.conf

    if [[ $ERR -eq 1 ]]; then
        print_results "Language error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_timezone
{
    ERR=0
	# Time zone
	print_pretty_header "Setting time zone${NC} $LOCALE"
	ln -sf /usr/share/zoneinfo/$LOCALE /etc/localtime || ERR=1
	echo $LOCALE > /etc/timezone
	#hwclock --systohc --utc

    if [[ $ERR -eq 1 ]]; then
        print_results "Time zone error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_initial_ramdisk
{
    ERR=0
	# Setting an initial ramdisk environment
	print_pretty_header "Setting initial ramdisk"
	mkinitcpio -p linux 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Ramdisk error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_root_passwd
{
    ERR=0
	# Setting root password
	print_pretty_header "Setting root password${NC} $ROOT_PASSWD"
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd

    if [[ $ERR -eq 1 ]]; then
        print_results "Root password error."
        exit 1
    else
    	let success+=1;
    fi
}

function install_basic_dependencies
{
    ERR=0
	# Installing basic installation dependencies
	print_pretty_header "Installing${NC} $BASIC_PKGS"
	pacman -S `echo $BASIC_PKGS` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Basic dependencies error."
        exit 1
    else
    	let success+=1;
    fi
}

function install_efi
{
    ERR=0
	# Install EFI
	mkdir /mnt/boot || ERR=1
	mount /dev/$EFI_BOOT /mnt/boot || ERR=1
	print_pretty_header "Installing EFI on${NC} /dev/$EFI_BOOT"
	grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=grub --boot-directory=/mnt/boot 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "EFI error."
        exit 1
    else
    	let success+=1;
    fi
}

function install_grub
{
    ERR=0
	# Making grub config
	print_pretty_header "Installing grub on${NC} /dev/$EFI_BOOT"  
	grub-mkconfig -o /mnt/boot/grub/grub.cfg 1>/dev/null || ERR=1
	umount /mnt/boot

    if [[ $ERR -eq 1 ]]; then
        print_results "Grub error."
        exit 1
    else
    	let success+=1;
    fi
}

##################################################
#           		Script                       #
##################################################

set_hostname
set_keyboard_layout
set_locale
set_language
set_timezone
set_initial_ramdisk
set_root_passwd
install_basic_dependencies
install_efi
install_grub

print_results 
print_line
