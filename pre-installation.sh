#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=3;
success=0;

##################################################
#                PRE-INSTALLATION                #
#              USING DUAL BOOT & EFI             #
##################################################

print_line() {
    printf "${BLUE}%$(tput cols)s\n${NC}"|tr ' ' '-'
}

print_results() {
    failed=$((to_install-success));

    if [[ $failed -eq 0 ]]; then
        echo -e "    $SUC_MS $to_install ${GREEN}Installed successfully.${NC}"
    else
        echo -e "    $SUC_MS $success ${GREEN}Installed successfully.${NC}"
        echo -e "    $FAIL_MS $failed ${RED}Failed to install.${NC}"
       	if [ ! -z "$1" ]; then
            echo -e "    $FAIL_MS ${RED}$1${NC}"
        fi
    fi   
}

function welcome
{
    clear
    echo -e "Welcome to ${RED}snackk's arch-linux${NC} installation script!"
    echo -e "This script will install arch-linux for a ${RED}Toshiba S50-b-131.${NC}"
    echo -e "${RED}!!WARNING!!${NC} Hardware dependencies."    
    print_line
    echo "Requirements:"
    echo "    -> Run script as root user"
    echo "    -> Internet connection"
    echo "    -> Coffee & Patience"
    print_line
    read -e -sn 1 -p "Press enter to continue..."
}

function make_root_fs
{
    ERR=0
    # Formats root partition to the specified File System
    echo -e "${BLUE}Formatting Root partition${NC}"
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
    echo -e "${BLUE}Mounting partitions${NC}"
    # Mount Root partition
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
    echo "${BLUE}Running pacstrap${NC}"
    pacstrap /mnt/linux base base-devel || ERR=1
    echo "${BLUE}Generating File System Table${NC}"
    genfstab -p /mnt/linux >> /mnt/linux/etc/fstab || ERR=1

    if [[ $ERR -eq 1 ]]; then
        print_results "Pacstrap error."
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
        [Yy]* ) echo "Good luck..."; break;;
        [Nn]* ) echo "Bye."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#### Preparation for the install
welcome
make_root_fs
mount_root_boot_partitions

#### Installing
install_system

### Copy necessary files
cp snackk.conf /mnt/linux
cp *.sh /mnt/linux

### Test
umount /mnt/boot

#### chroot and configure the base system
arch-chroot /mnt/linux << EOF
print_results
if [[ $success -ne $to_install ]]; then
    echo -e "${RED}Please fix the errors and come back again.${NC}"
    exit
fi  

print_line
echo "Running ./post-installation.sh"
./post-installation.sh
EOF

echo "Umounting partitions"
umount /mnt/linux
### umount /mnt/boot
shutdown -r 10 "After it reboots, run ./snackk-installation.sh"

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