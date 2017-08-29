#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=11;
success=0

##################################################
#                  SNACKK-SETUP                  #
##################################################

function run_osprober
{
    ERR=0
	# OS-prober
	print_pretty_header "Running OS-prober${NC} /dev/$EFI_BOOT"
	os-prober 1>/dev/null || ERR=1
	mount /dev/$EFI_BOOT /mnt/boot
	grub-mkconfig -o /mnt/boot/grub/grub.cfg 1>/dev/null || ERR=1
	umount /mnt/boot

    if [[ $ERR -eq 1 ]]; then
        echo "OS-prober error."
        exit 1
    else
    	let success+=1;
    fi
}

function add_user
{
    ERR=0
	# Add user
	print_pretty_header "Adding user${NC} $USERN"
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
    ERR=0
	# Setting $USERN password
	print_pretty_header "Setting password${NC} $ROOT_PASSWD"
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd $USERN

    if [[ $ERR -eq 1 ]]; then
        echo "Set user error."
        exit 1
    else
    	let success+=1;
    fi
}

function pacman_config
{
    ERR=0
	# Configure pacman
	print_pretty_header "Adding multilib & aur"
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[multilib]" >> /etc/pacman.conf || ERR=1
	echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf || ERR=1
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[archlinuxfr]" >> /etc/pacman.conf || ERR=1
	echo "SigLevel = Never" >> /etc/pacman.conf || ERR=1
	echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf || ERR=1
	print_pretty_header "Updating repositories"
	pacman -Syy 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman config error."
        exit 1
    else
    	let success+=1;
    fi
}

function set_sudoers
{
    ERR=0
    # Setting sudoers file
    print_pretty_header "Setting up sudoers"
    sed -i -e 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers || ERR=1
    sed -i -e 's/# %sudo ALL=(ALL) ALL/%sudo ALL=(ALL) ALL/g' /etc/sudoers || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Sudoers error."
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
	pacman -Sy yaourt --noconfirm 1>/dev/null || ERR=1
	print_pretty_header "Installing${NC} $AUR_PKGS"
        $ROOT_PASSWD"\n"$ROOT_PASSWD | sudo -u	snackk yaourt -S `echo $AUR_PKGS` --noconfirm 1>/dev/null || ERR=1
	print_pretty_header "Resetting initial ramdisk"	
	mkinitcpio -p linux 1>/dev/null || ERR=1

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
	print_pretty_header "Installing${NC} $PAC_PKGS"
	pacman -S `echo $PAC_PKGS` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman dependencies error."
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

function deepin_dde
{
    ERR=0
	# Adding some nice touch :D
	print_pretty_header "Installing Deepin"
	pacman -S `echo $DEEPIN` --noconfirm 1>/dev/null || ERR=1
	sed -i -e 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-deepin-greeter/g' /etc/lightdm/lightdm.conf || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Deepin dde error."
        exit 1
    else
    	let success+=1;
    fi
}

function enable_sysctl_daemons
{
    ERR=0
    # Daemons
    print_pretty_header "Enabling NetworkManager and Lightdm"
    systemctl enable NetworkManager.service 1>/dev/null || ERR=1
    systemctl enable lightdm.service 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Systemctl daemons error."
        exit 1
    else
        let success+=1;
    fi
}

function set_dns
{
    ERR=0
    # Google's DNS
    print_pretty_header "Setting Google's DNS"
    echo "[main]" >> /etc/NetworkManager/NetworkManager.conf || ERR=1
    echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf || ERR=1
    rm /etc/resolv.conf
    touch /etc/resolv.conf
    echo "# Google IPv4 nameservers" >> /etc/resolv.conf || ERR=1
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf || ERR=1
    echo "nameserver 8.8.4.4" >> /etc/resolv.conf || ERR=1	

    if [[ $ERR -eq 1 ]]; then
        echo "DNS error."
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
set_sudoers
aur_dependecies
pacman_dependecies
blacklist_speaker
deepin_dde
enable_sysctl_daemons
set_dns

print_results
print_line
