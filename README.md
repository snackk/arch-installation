# arch-installation

### Credits

This script installation is based upon [Anarchy](https://github.com/magnunleno/Anarchy), they made a huge effort on making this happen, and they deserve all credits, not me!

### About

This script should be executed upon booted the arch-linux image. The installation is divided in 3 stages:
* Pre-installation - Will install arch-linux base and base-devel.
* Post-installation - Basic config stuff, hostname, username and grub.
* snackk-installation - After reboot, will run os-prober, create new user, add AUR and multilib, install dependencies that are defined on the .conf file.

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
Any problem with install just run:
```sh
$ chmod +x pre-installation.sh pos-installation.sh snackk-installation.sh
```
  
  Written by Diogo Santos.
