#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=9;
success=0

##################################################
#                ENVIRONMENT-SETUP               #
##################################################

function run_osprober
{
    ERR=0

	# os-prober
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

	# Setting User password
	print_pretty_header "Setting password${NC} $ROOT_PASSWD"
	echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd $USERN

    if [[ $ERR -eq 1 ]]; then
        echo "Set user error."
        exit 1
    else
    	let success+=1;
    fi
}

function add_repositories
{
    ERR=0

	# Configure pacman
	print_pretty_header "Adding multilib & aur"
    sed -i '/^#VerbosePkgLists/ a ILoveCandy' /etc/pacman.conf || ERR=1
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[multilib]" >> /etc/pacman.conf || ERR=1
	echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf || ERR=1
	echo "" >> /etc/pacman.conf || ERR=1
	echo "[archlinuxfr]" >> /etc/pacman.conf || ERR=1
	echo "SigLevel = Never" >> /etc/pacman.conf || ERR=1
	echo "Server = http://repo.archlinux.fr/x86_64" >> /etc/pacman.conf || ERR=1
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

    # Setting sudoers
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

function pacman_display_dependecies
{
    ERR=0

	# Downloading pacman display dependencies
	print_pretty_header "Installing${NC} $DISPLAY_PKGS"
	pacman -S `echo $DISPLAY_PKGS` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman Display dependencies error."
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

    # CloudFlare's DNS
    print_pretty_header "Setting CloudFlare DNS"
    echo "[main]" >> /etc/NetworkManager/NetworkManager.conf || ERR=1
    echo "dns=none" >> /etc/NetworkManager/NetworkManager.conf || ERR=1
    rm /etc/resolv.conf
    touch /etc/resolv.conf
    echo "# CloudFlare IPv4 nameservers" >> /etc/resolv.conf || ERR=1
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf || ERR=1
    echo "nameserver 1.0.0.1" >> /etc/resolv.conf || ERR=1

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
add_repositories
set_sudoers
pacman_display_dependecies
deepin_dde
enable_sysctl_daemons
set_dns

print_results
print_line