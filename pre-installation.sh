#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=3;

##################################################
#                PRE-INSTALLATION                #
#             USING DUAL BOOT ON EFI             #
##################################################

function welcome
{
    clear
    echo -e "    Welcome to ${RED}snackk's${NC} arch-linux installation script!"
    echo -e "    This script will install ${BLUE}arch-linux${NC} for a ${RED}Toshiba S50-b-131.${NC}"
    echo -e "    ${RED}!!WARNING!!${NC} Use at your own risk."    
    echo "    Requirements:"
    echo "        -> Run script as ${RED}root${NC}"
    echo "        -> Internet connection"
    echo "        -> Coffee & just chill"
    print_line
    read -e -sn 1 -p "Press enter to continue..."
}

function make_root_fs
{
    ERR=0
    # Formats root partition to the specified File System
    print_pretty_header "Formatting Root partition"
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
    print_pretty_header "Mounting partitions"
    # Mount Root partition
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
    print_pretty_header "Running pacstrap"
    pacstrap /mnt/linux base base-devel 1>/dev/null || ERR=1
    print_pretty_header "Generating fstab"
    genfstab -p /mnt/linux >> /mnt/linux/etc/fstab 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Install system error."
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
    read -p "Hardware dependencies, continue anyway [y/n]? " yn
    case $yn in
        [Yy]* ) echo "GG..."; break;;
        [Nn]* ) echo "LOL n00b."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#### Preparation for the install
welcome
make_root_fs
mount_root_boot_partitions

#### Instalation
install_system

### Copy necessary files
cp snackk.conf /mnt/linux/arch-installation
cp *.sh /mnt/linux/arch-installation

### Unmount boot partition
umount /mnt/boot

print_results
if [[ $success -ne $to_install ]]; then
    echo -e "${RED}Check the FAQ for diagnostics.${NC}"
    exit 0
fi
print_line

#### chroot and configure the base system
arch-chroot /mnt/linux << EOF  

./post-installation.sh
EOF

print_pretty_header "Unmounting partitions"
umount /mnt/linux
print_pretty_header "Computer will shutdown. Power it on and run ./snackk-installation.sh"
shutdown -h +1 ""



##################################################
#               USING ALL HARDDRIVE              #
#                   ! NOT USED !                 #
##################################################

function initialize_harddrive
{
    echo "Initializing HD"
    # Setting the type of partition table (Skipping errors)
    parted -s $HD mklabel msdos &> /dev/null

    # Remove ALL partitions
    parted -s $HD rm 1 &> /dev/null
    parted -s $HD rm 2 &> /dev/null
    parted -s $HD rm 3 &> /dev/null
    parted -s $HD rm 4 &> /dev/null
}

function make_partitions
{
    ERR=0
    # Create Boot partition
    echo "Creating Boot partition"
    parted -s $HD mkpart primary $BOOT_FS $BOOT_START $BOOT_END 1>/dev/null || ERR=1
    parted -s $HD set 1 boot on 1>/dev/null || ERR=1

    # Create Swap partition
    echo "Creating Swap partition"
    parted -s $HD mkpart primary linux-swap $SWAP_START $SWAP_END 1>/dev/null || ERR=1

    # Create Root partition
    echo "Creating Root partition"
    parted -s $HD mkpart primary $ROOT_FS $ROOT_START $ROOT_END 1>/dev/null || ERR=1

    # Create Home partition
    echo "Creating Home partition"
    parted -s -- $HD mkpart primary $HOME_FS $HOME_START -0 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Partition error"
        exit 1
    fi
}

function make_ALL_fs
{
    ERR=0
    # Formats root, boot and home partitions to the specified File System
    echo "Formatting Boot partition"
    mkfs.$BOOT_FS /dev/sda1 -L Boot 1>/dev/null || ERR=1
    echo "Formatting Root partitiont"
    mkfs.$ROOT_FS /dev/sda3 -L Root 1>/dev/null || ERR=1
    echo "Formatting Home partition"
    mkfs.$HOME_FS /dev/sda4 -L Home 1>/dev/null || ERR=1
    # Create and initializes the swap
    echo "Formatting Swap partition"
    mkswap /dev/sda2 || ERR=1
    swapon /dev/sda2 || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "File Systems error"
        exit 1
    fi
}

function mount_ALL_partitions
{
    ERR=0
    echo "Mounting partitions"
    # Mount Root partition
    mount /dev/$ROOT_PART /mnt || ERR=1
    # Mount Boot partition
    mkdir /mnt/boot || ERR=1
    mount /dev/sda1 /mnt/boot || ERR=1
    # Mount Home partition
    mkdir /mnt/home || ERR=1
    mount /dev/sda4 /mnt/home || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Mounting error"
        exit 1
    fi
}
