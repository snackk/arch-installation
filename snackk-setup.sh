#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=7;

##################################################
#                  SNACKK-SETUP                  #
##################################################

function pacman_dependecies
{
    ERR=0

    # Downloading Pacman dependencies
    print_pretty_header "Installing${NC} $SNK_CUSTOM"
    
    echo -e $ROOT_PASSWD | sudo -s << EOF
pacman -S `echo $SNK_CUSTOM` --noconfirm || ERR=1
EOF

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman dependencies error."
        exit 1
    else
        let success+=1;
    fi
}

function grub_theme
{
    ERR=0

    # Downloading grub theme
    print_pretty_header "Installing${NC} $GRUB_THEME"
    sudo -i -u $USERN yay -S `echo $GRUB_THEME` --noconfirm 1>/dev/null || ERR=1
    echo -e $ROOT_PASSWD | echo 'GRUB_THEME="/boot/grub/themes/Vimix/theme.txt"' | sudo tee -a /etc/default/grub > /dev/null || ERR=1
    echo -e $ROOT_PASSWD | sudo -S mount /dev/$EFI_BOOT /mnt || ERR=1
    echo -e $ROOT_PASSWD | sudo -S grub-mkconfig -o /mnt/boot/grub/grub.cfg 1>/dev/null || ERR=1 

    if [[ $ERR -eq 1 ]]; then
        echo "Grub theme error."
        exit 1
    else
        let success+=1;
    fi
}

function set_zsh
{
    ERR=0

    # Setting zsh
    print_pretty_header "Setting ZSH as default shell"
    echo -e $ROOT_PASSWD | chsh -s /usr/bin/zsh 1>/dev/null || ERR=1
    echo -e $ROOT_PASSWD | su -c chsh -s /usr/bin/zsh 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "ZSH error."
        exit 1
    else
        let success+=1;
    fi
}

function install_oh_my_zsh
{
    ERR=0

    # Installing oh-my-zsh
    print_pretty_header "Installing oh-my-zsh"
    cd $HOME
    echo -e $ROOT_PASSWD | sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "ZSH error."
        exit 1
    else
        let success+=1;
    fi
}

function install_zsh_powerline
{
    ERR=0

    # Installing powerline fonts
    print_pretty_header "Installing powerline fonts"
    mkdir $HOME/git 1>/dev/null || ERR=1
    cd $HOME/git 1>/dev/null || ERR=1
    git clone https://github.com/powerline/fonts.git --depth=1 1>/dev/null || ERR=1
    # install
    cd fonts 1>/dev/null || ERR=1
    ./install.sh 1>/dev/null || ERR=1
    # clean-up the mess
    cd .. 1>/dev/null || ERR=1
    rm -rf fonts 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Powerline error."
        exit 1
    else
        let success+=1;
    fi
}

function install_awesome_vimrc
{
    ERR=0

    print_pretty_header "Installing an awesome vimrc"
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime 1>/dev/null || ERR=1
    # install
    sh ~/.vim_runtime/install_awesome_vimrc.sh 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Vimrc error."
        exit 1
    else
        let success+=1;
    fi
}

function install_config_files
{
    ERR=0

    print_pretty_header "Installing arch-config-files"
    cd $HOME/git 1>/dev/null || ERR=1
    git clone https://github.com/snackk/arch-config-files 1>/dev/null || ERR=1
    # install
    cd arch-config-files 1>/dev/null || ERR=1
    ./install.sh 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "arch-config-files error."
        exit 1
    else
        let success+=1;
    fi
}

##################################################
#                   Script                       #
##################################################

pacman_dependecies
#grub_theme
set_zsh
install_oh_my_zsh
install_zsh_powerline
install_awesome_vimrc
install_config_files

print_results
print_line