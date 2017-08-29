#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=10;

##################################################
#               POST-INSTALLATION                #
##################################################

function set_hostname
{
    ERR=0
	# Hostname
	echo -e "${BLUE}Setting Hostname${NC}"
	echo $HOSTN > /etc/hostname || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Hostname error."
        exit 1
    else
    	let success+=1;
    fi
}

function keyboard_layout
{
    ERR=0
	# Keybord Layout
	echo -e "${BLUE}Setting Keyboard layout${NC}"
	echo 'KEYMAP='$KEYBOARD_LAYOUT > /etc/vconsole.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Keyboard Layout error."
        exit 1
    else
    	let success+=1;
    fi
}

function gen_locale
{
    ERR=0
	# Locale locale.gen
	echo -e "${BLUE}Setting locale${NC}"
	sed -i 's/^#'$LANGUAGE'/'$LANGUAGE/ /etc/locale.gen || ERR=1
	locale-gen

    if [[ $ERR -eq 1 ]]; then
        print_results "Locale gen error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_language
{
    ERR=0
	# Locale locale.conf
	echo -e "${BLUE}Configuring language${NC}"
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
	echo -e "${BLUE}Configuring time zone${NC}"
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

function initial_ramdisk
{
    ERR=0
	# Create an initial ramdisk environment
	echo -e "${BLUE}Creating initial ramdisk${NC}"
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
	echo -e "${BLUE}Changing root password${NC}"
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd

    if [[ $ERR -eq 1 ]]; then
        print_results "Root password error."
        exit 1
    else
    	let success+=1;
    fi
}

function basic_dependencies
{
    ERR=0
	#Installing basic installation dependencies
	echo -e "${BLUE}Running pacman -S${NC} $BASIC_PKGS"
	pacman -S `echo $BASIC_PKGS` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Basic dependencies error."
        exit 1
    else
    	let success+=1;
    fi
}

function efi
{
    ERR=0
	# Install EFI
    	mkdir /mnt/boot || ERR=1
    	mount /dev/$EFI_BOOT /mnt/boot || ERR=1
	echo -e "${BLUE}Installing EFI on${NC} /dev/$EFI_BOOT"
	grub-install --target=x86_64-efi --efi-directory=/mnt/boot --bootloader-id=grub --boot-directory=/mnt/boot 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "EFI error."
        exit 1
    else
    	let success+=1;
    fi
}

function grub
{
    ERR=0
	# Making grub config
	echo -e "${BLUE}Making grub config${NC}"
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
#           		Script                   #
##################################################

set_hostname
keyboard_layout
gen_locale
set_language
set_timezone
initial_ramdisk
set_root_passwd
basic_dependencies
efi
grub

print_results 
print_line
