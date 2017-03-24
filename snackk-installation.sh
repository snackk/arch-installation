#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=8;
success=0

##################################################
#              SNACKK-INSTALLATION               #
##################################################

print_line() {
    printf "%$(tput cols)s\n"|tr ' ' '-'
}

print_results() {
    failed=$success - $to_install;

    if [[ $failed -eq 0 ]]; then
        echo -e "    $SUC_MS Installed all successfully."
    else
        echo -e "    $SUC_MS  $success Installed successfully." 
        echo -e "    $FAIL_MS $failed Failed to install."
        echo -e "    $FAIL_MS $1"
    fi   
}

function run_osprober
{
    ERR=0
	# OS-prober
	echo "Running OS-prober..."
	os-prober
	mount /dev/$EFI_BOOT /mnt
	grub-mkconfig -o /mnt/grub/grub.cfg || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Run osprober error"
        exit 1
    else
    	let success+=1;
    fi
}

function add_user
{
    ERR=0
	# Add user
	echo "Adding new user $USERN ..."
	useradd -m -G wheel -s /bin/bash $USERN || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Add user error"
        exit 1
    else
    	let success+=1;
    fi
}

function set_user_passwd
{
	# Setting $USERN password
	echo "Changing $USERN password..."
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd $USERN
}

function pacman_config
{
    ERR=0
	# Configure pacman
	echo "Adding Multilib & AUR"
	sed -i 's/^#[multilib]/[multilib]/' /etc/pacman.conf || ERR=1
	echo "[archlinuxfr]" >> /etc/pacman.conf || ERR=1
	echo "SigLevel = Never" >> /etc/pacman.conf || ERR=1
	echo "Server = http://repo.archlinux.fr/$arch" >> /etc/pacman.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman config error"
        exit 1
    else
    	let success+=1;
    fi
}

function aur_dependecies
{
    ERR=0
	# Downloading AUR dependencies
	echo "Downloading AUR dependencies..."
	pacman -Sy yaourt
	yaourt -S `echo $AUR_PKGS`
	mkinitcpio -p Linux

    if [[ $ERR -eq 1 ]]; then
        echo "AUR dependencies error"
        exit 1
    else
    	let success+=1;
    fi
}

function pacman_dependecies
{
    ERR=0
	# Downloading PACMAN dependencies
	echo "Downloading pacman dependencies..."
	pacman -S `echo $PAC_PKGS`

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman dependencies error"
        exit 1
    else
    	let success+=1;
    fi
}

function blacklist
{
    ERR=0
	# Add anoying beep to blacklist
	echo "Blacklisting speaker!"
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Blacklist error"
        exit 1
    else
    	let success+=1;
    fi
}

function deepin_dde
{
    ERR=0
	# Adding some nice touch :D
	echo "Installing deepin..."
	pacman -S `echo $DEEPIN` || ERR=1
	#Need to edit /etc/lightdm/lightdm.conf
	#greeter-session=lightdm-deepin-greeter

    if [[ $ERR -eq 1 ]]; then
        echo "Deepin dde error"
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
aur_dependecies
pacman_dependecies
blacklist
deepin_dde

print_results
print_line