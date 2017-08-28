# arch-installation

### Credits

This script is based on this project [Anarchy](https://github.com/magnunleno/Anarchy), they made a huge effort on customizing the arch-linux iso.

### About

Before anything, a customized image of arch-linux must be built, in order for the scripts to work. After that, the installation is divided in 3 stages:
* Pre-installation - Will install arch-linux base and base-devel.
* Post-installation - Basic config stuff, hostname, username and grub.
* snackk-installation - After reboot, will run os-prober, create new user, add AUR and multilib to the repositories, and install dependencies that are defined on the .conf file.

### Customizing image

```sh
$ make ISO=~/Downloads/archlinux-2017.08.01-dual.iso
$ make iso
```
Final iso will be available at ./build/out/

### Installation
### WARNING: My .conf file contains specific hardware dependencies, and may break your system!

```sh
$ loadkeys pt-latin9
```
If internet is up, you're ready to go! Jump to #Pre-installation.

### Internet
Wireless:
```sh
$ wifi-menu
```

Wired:
```sh
$ dhcpcd
```

 ### Pre-installation
```sh
$ ./pre-installation.sh
```

 ### Post-installation
 Will run automatically.

 ### snackk-installation
 After the reboot, run:
```sh
$ ./snackk-installation.sh
```
 
 ### Problems
 If you can't run the scripts:
```sh
$ chmod +x pre-installation.sh pos-installation.sh snackk-installation.sh
```
  
  Written by Diogo Santos.
