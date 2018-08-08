#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=3;

##################################################
#        XIAOMI-NOTEBOOK-PRO-INSTALLATION        #
##################################################

HARDWARE_PKGS='aic94xx-firmware wd719x-firmware'
DISPLAY_DRIVERS='intel-vulkan nvidia bumblebee'

function display_drivers
{
    ERR=0

   # Intalling display drivers
   print_pretty_header "Installing${NC} $DISPLAY_DRIVERS"
   pacman -S `echo $DISPLAY_DRIVERS` --noconfirm 1>/dev/null || ERR=1
   # Setting daemon and user to bumblebee group
   systemctl enable bumblebeed.service 1>/dev/null || ERR=1
   gpasswd -a $USERN bumblebee  1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Installing display drivers error."
        exit 1
    else
        let success+=1;
    fi
}

function blacklist_nouveau
{
    ERR=0

   # Supress nouveau driver
   print_pretty_header "Blacklisting nouveau"
   echo "blacklist nouveau" > /etc/modprobe.d/nouveau.conf || ERR=1

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

display_drivers
blacklist_nouveau
missing_hardware_dependecies

print_results
print_line



