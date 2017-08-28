#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=8;
success=0

##################################################
#              SNACKK-INSTALLATION               #
##################################################

function run_osprober
{
    ERR=0
	# OS-prober
	echo -e "${BLUE}Running OS-prober${NC}"
	os-prober
	mount /dev/$EFI_BOOT /mnt/boot
	grub-mkconfig -o /mnt/grub/grub.cfg || ERR=1
	umount /mnt/boot

    if [[ $ERR -eq 1 ]]; then
        echo "osprober error."
        exit 1
    else
    	let success+=1;
    fi
}

function add_user
{
    ERR=0
	# Add user
	echo -e "${BLUE}Adding new user${NC} $USERN"
	useradd -m -G wheel -s /bin/bash $USERN || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Add user error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_user_passwd
{
	# Setting $USERN password
	echo -e "${BLUE}Changing $USERN password${NC}"
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd $USERN
}

function pacman_config
{
    ERR=0
	# Configure pacman
	echo -e "${BLUE}Adding Multilib & AUR${NC}"
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[multilib]" >> /etc/pacman.conf || ERR=1
	echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf || ERR=1
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[archlinuxfr]" >> /etc/pacman.conf || ERR=1
	echo "SigLevel = Never" >> /etc/pacman.conf || ERR=1
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman config error."
        exit 1
    else
    	let success+=1;
    fi
}

function aur_dependecies
{
    ERR=0
	# Downloading AUR dependencies
	echo -e "${BLUE}Downloading AUR dependencies${NC}"
	pacman -Sy yaourt --noconfirm || ERR=1
	sudo -u snackk bash
	yaourt -S `echo $AUR_PKGS` --noconfirm || ERR=1
	exit
	mkinitcpio -p Linux || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "AUR dependencies error."
        exit 1
    else
    	let success+=1;
    fi
}

function pacman_dependecies
{
    ERR=0
	# Downloading PACMAN dependencies
	echo -e "${BLUE}Downloading pacman dependencies${NC}"
	pacman -S `echo $PAC_PKGS` --noconfirm || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman dependencies error."
        exit 1
    else
    	let success+=1;
    fi
}

function blacklist
{
    ERR=0
	# Add anoying beep to blacklist
	echo -e "${BLUE}Blacklisting speaker${NC}"
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Blacklist error."
        exit 1
    else
    	let success+=1;
    fi
}

function deepin_dde
{
    ERR=0
	# Adding some nice touch :D
	echo -e "${BLUE}Installing deepin${NC}"
	pacman -S `echo $DEEPIN` --noconfirm || ERR=1
	echo "greeter-session=lightdm-deepin-greeter" >> /etc/lightdm/lightdm.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Deepin dde error."
        exit 1
    else
    	let success+=1;
    fi
}

##################################################
#           		Script                       #
##################################################

run_osprober
add_user
set_user_passwd
pacman_config
#aur_dependecies
pacman_dependecies
blacklist
deepin_dde

print_results
print_line
