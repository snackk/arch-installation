#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=3;

##################################################
#               ARCH-INSTALLATION                #
##################################################

function welcome
{
    clear
    echo -e "    Welcome to ${RED}snackk's${NC} arch-linux installation script!"
    echo -e "    This script will install ${BLUE}arch-linux${NC} on ${RED}/dev/$ROOT_PART${NC}"
    echo -e "    EFI partition ${RED}/dev/$EFI_BOOT${NC}"    
    echo "    Requirements:"
    echo -e "        -> Run script as ${RED}root${NC}"
    echo "        -> Internet connection"
    echo "        -> Go grab a coffee & chill"
    print_line
    read -e -sn 1 -p "Press enter to continue..."
}

function make_mirrorlist_by_speed
{
    ERR=0

    # Orders the mirrorlist by speed
    print_pretty_header "Ordering mirrorlist by speed:${NC} /etc/pacman.d/mirrorlist"
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup 1>/dev/null || ERR=1
    sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup 1>/dev/null || ERR=1
    rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

    if [[ $ERR -eq 1 ]]; then
        print_results "Mirrorlist error."
        exit 1
    else
        let success+=1;
    fi
}

function make_root_fs
{
    ERR=0

    # Formats root partition to the specified File System
    print_pretty_header "Formatting root partition${NC} /dev/$ROOT_PART"
    mkfs.$ROOT_FS /dev/$ROOT_PART -L Root 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "File Systems error."
        exit 1
    else
        let success+=1;
    fi
}

function mount_root_boot_partitions
{
    ERR=0

    # Mount Root partition
    print_pretty_header "Mounting partitions${NC} /dev/$ROOT_PART /dev/$EFI_BOOT"
    mkdir /mnt/linux || ERR=1
    mount /dev/$ROOT_PART /mnt/linux || ERR=1
    # Mount Boot partition
    mkdir /mnt/boot || ERR=1
    mount /dev/$EFI_BOOT /mnt/boot || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Mounting error."
        exit 1
    else
        let success+=1;
    fi
}

function install_system
{
    ERR=0

    # Installing base system
    print_pretty_header "Running pacstrap${NC} $BASE_PKGS"
    pacstrap /mnt/linux `echo $BASE_PKGS` 1>/dev/null || ERR=1
    print_pretty_header "Building fstab"
    genfstab -p /mnt/linux >> /mnt/linux/etc/fstab 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Install systems error."
        exit 1
    else
        let success+=1;
    fi
}

##################################################
#                   Script                       #
##################################################

# Load Keybord Layout
loadkeys $KEYBOARD_LAYOUT

while true; do
    read -p "Install arch-linux [y/n]? " yn
    case $yn in
        [Yy]* ) echo "Good Luck ;)"; break;;
        [Nn]* ) echo "Wise choice."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#### Preparation for the install
welcome

# make_mirrorlist_by_speed #mirrolist inst working as of right now on arch-linux
make_root_fs
mount_root_boot_partitions

#### Instalation
install_system

### Copy necessary files
cp snackk.conf /mnt/linux
cp *.sh /mnt/linux

### Unmount boot partition
umount /mnt/boot

print_results
if [[ $success -ne $to_install ]]; then
    echo -e "${RED}Check the FAQ for your problem.${NC}"
    exit 0
fi
print_line

#### chroot and configure the base system
arch-chroot /mnt/linux << EOF  
./arch-configuration.sh
EOF

print_pretty_header "Unmounting partitions now."
umount /mnt/linux
print_pretty_header "Computer will shutdown."
print_pretty_header "Power it on and run ./environment-setup.sh"
shutdown -h +1 ""