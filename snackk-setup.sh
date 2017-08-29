#!/bin/bash
# encoding: utf-8

source snackk.conf

to_install=5;

##################################################
#                  SNACKK-SETUP                  #
##################################################

function pacman_dependecies
{
    ERR=0
    # Downloading PACMAN dependencies
    print_pretty_header "Installing${NC} $SNK_CUSTOM"
    echo -e $ROOT_PASSWD | sudo pacman -S `echo $SNK_CUSTOM` --noconfirm 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Pacman dependencies error."
        exit 1
    else
        let success+=1;
    fi
}

function set_zsh
{
    ERR=0
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
    print_pretty_header "Installing Oh-My-Zsh"
    cd $HOME
    echo -e $ROOT_PASSWD | sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "ZSH error."
        exit 1
    else
        let success+=1;
    fi
}

function install_powerline
{
    ERR=0
    print_pretty_header "Installing powerline"
    mkdir $HOME/git 1>/dev/null || ERR=1
    cd $HOME/git 1>/dev/null || ERR=1
    git clone https://github.com/powerline/fonts.git --depth=1 1>/dev/null || ERR=1
    # install
    cd fonts 1>/dev/null || ERR=1
    ./install.sh 1>/dev/null || ERR=1
    # clean-up a bit
    cd .. 1>/dev/null || ERR=1
    rm -rf fonts 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Powerline error."
        exit 1
    else
        let success+=1;
    fi
}

function install_config_files
{
    ERR=0
    print_pretty_header "Installing config-files"
    cd $HOME/git 1>/dev/null || ERR=1
    git clone https://github.com/snackk/config-files 1>/dev/null || ERR=1
    # install
    cd config-files 1>/dev/null || ERR=1
    ./install.sh 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Config-files error."
        exit 1
    else
        let success+=1;
    fi
}

##################################################
#                   Script                       #
##################################################

pacman_dependecies
set_zsh
install_oh_my_zsh
install_powerline
install_config_files

print_results
print_line



