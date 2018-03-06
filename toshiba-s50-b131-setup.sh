#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=2;

##################################################
#             TOSHIBA-INSTALLATION               #
##################################################

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

function aur_dependecies
{
    ERR=0
    # Downloading AUR dependencies
    print_pretty_header "Downloading yaourt"
    echo -e $ROOT_PASSWD | sudo -S pacman -Sy yaourt --noconfirm || ERR=1
    print_pretty_header "Installing${NC} $AUR_PKGS"
    sudo -i -u $USERN yaourt -S `echo $AUR_PKGS` --noconfirm 1>/dev/null || ERR=1
    print_pretty_header "Resetting initial ramdisk" 
    echo -e $ROOT_PASSWD | sudo -S mkinitcpio -p linux || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "AUR dependencies error."
        exit 1
    else
        let success+=1;
    fi
}

##################################################
#                   Script                       #
##################################################

blacklist_speaker
aur_dependecies

print_results
print_line



