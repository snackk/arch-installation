#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=3;

##################################################
#          TOSHIBA-S50-B131-INSTALLATION         #
##################################################

HARDWARE_PKGS='aic94xx-firmware wd719x-firmware'
DISPLAY_DRIVERS='xf86-video-intel xf86-input-libinput'

function display_drivers
{
    ERR=0

   # Intalling display drivers
   print_pretty_header "Installing${NC} $DISPLAY_DRIVERS"
   pacman -S `echo $DISPLAY_DRIVERS` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Installing display drivers error."
        exit 1
    else
        let success+=1;
    fi
}

function blacklist_speaker
{
    ERR=0

	# Supress anoying beep
	print_pretty_header "Blacklisting speaker"
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Blacklist error."
        exit 1
    else
    	let success+=1;
    fi
}

function missing_hardware_dependecies
{
    ERR=0

    # Downloading Hardware dependencies
    print_pretty_header "Installing${NC} $HARDWARE_PKGS"
    sudo -i -u $USERN yaourt -S `echo $HARDWARE_PKGS` --noconfirm 1>/dev/null || ERR=1
    print_pretty_header "Resetting initial ramdisk" 
    echo -e $ROOT_PASSWD | sudo -S mkinitcpio -p linux || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Hardware dependencies error."
        exit 1
    else
        let success+=1;
    fi
}

##################################################
#                   Script                       #
##################################################

display_drivers
blacklist_speaker
missing_hardware_dependecies

print_results
print_line



