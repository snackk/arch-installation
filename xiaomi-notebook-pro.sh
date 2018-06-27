#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=2;

##################################################
#             XIAOMI-NOTEBOOK-PRO-INSTALLATION      #
##################################################

HARDWARE_PKGS='aic94xx-firmware wd719x-firmware'

function blacklist_nouveau
{
    ERR=0
    # Supress nvidea card
    print_pretty_header "Blacklisting nouveau"
    echo "blacklist nouveau" > /etc/modprobe.d/nouveau.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Blacklist error."
        exit 1
    else
        let success+=1;
    fi
}

function hardware_dependecies
{
    ERR=0
    # Downloading Hardware dependencies
    print_pretty_header "Downloading hardware dependencies"
    echo -e $ROOT_PASSWD | sudo -S pacman -Sy yaourt --noconfirm || ERR=1
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

blacklist_nouveau
hardware_dependecies

print_results
print_line



