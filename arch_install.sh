#!/bin/bash

BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
WHITE=$(tput sgr0)

clear
echo "${GREEN}Welcome to my arch install script!${WHITE}"

system=$(cat /sys/firmware/efi/fw_platform_size)
if [ "$system" = 64 ]
then
system=EFI
else
system=BIOS
fi
choicexit(){
echo "
       exit without save
"
exit
}
printgraph(){
echo "
    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}

         ${BLUE}your choice${WHITE}


            bios mode               - $system
            root partition          - $rootpart
            boot partition          - $bootpart
            swap partition          - $swappart
            locale                  - $locale
            timezone                - $timezone
            user                    - $username
            hostname                - $hostname
            kernel                  - $kernel"
if [ "$system" = EFI ]
then
echo "            (EFI) bootloader name   - $efiboot"
else
echo "            (BIOS) disk for grub    - $biosdisk"
fi
echo "            network                 - $network
            desktop environment     - $desktop
            display manager         - $display
            additional packages     - $extrapackages

    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}
printanswer(){
echo "    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}
$answer
    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}

printpart(){
echo "    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}

         ${BLUE}Partitioning...${WHITE}


$(lsblk | awk '{print "            " $0}')

    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}

answersystem(){
clear
answer="
        script detected $system mode

            Do you want change to another?
            s) - skip
            yes) - EFI > BIOS or vice versa
            any) - exit without change

"
printgraph
printanswer
read -p "           Your choice: " systemans
    case $systemans in
    yes)
        if [ "$system" = EFI ]
        then
        system=BIOS
        else
        system=EFI
        fi
    ;;
    s)
    ;;
    *)
    choicexit
    ;;
    esac
}

answerpart(){
clear
answer="

            Do you want to change the partitions?
            s) - skip
            yes) - open gparted
            any) - exit without change

"
printpart
printanswer
read -p "         Your choice: " part
    case $part in
    yes)
    cfdisk
    ;;
    s)
    ;;
    *)
    choicexit
    ;;
    esac
}

answerrootpart(){
clear
answer="

		Which partition you want to root (/)? (sdx# (eg.: sda2))

"
printpart
printanswer
read -p "         Your choice: " rootpart
}

answerbootpart(){
clear
answer="

		Which partition you want to boot? (sdx# (eg.: sda2))

"
printpart
printanswer
read -p "         Your choice: " bootpart
}

answerswappart(){
clear
answer="

		Do you want a swap partition?
			yes or no
"
printpart
printanswer
read -p "         Your choice: " swappart
    case $swappart in
    yes)
	swap
    ;;
    no)
	break
    ;;
    *)
    choicexit
    ;;
    esac
}

swap(){
clear
answer="

		Which partition you want to swap? (eg.: sda3)
			
"
printpart
printanswer
read -p "         Your choice: " swappart

mkswap /dev/$swappart
swapon /dev/$swappart
}

answerlocale(){
clear
answer="
        Choose locale (example hu_HU for Hungarian)

            s) - skip
            d) - default (en_US)
            empty) - exit without save

"
printgraph
printanswer
read -p "         Your choice: " localeans
    if [ -z "$localeans" ]
    then
    choicexit
    fi
    case $localeans in
    s)
    ;;
    d)
    locale=en_US
    ;;
    *)
    locale=$localeans
    ;;
    esac
}

answertimezone(){
clear
answer='
        Choose timezone (example Europe/Budapest)

            s) - skip
            d) - default (default Europe/London)
            empty) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " timezoneans
    if [ -z "$timezoneans" ]
    then
    choicexit
    fi
    case $timezoneans in
    s)
    ;;
    d)
    timezone="Europe/London"
    ;;
    *)
    timezone=$timezoneans
    ;;
    esac
}

answeruser(){
clear
answer='
         username:

            s) - skip
            empty) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " usernameans
    if [ -z "$usernameans" ]
    then
    choicexit
    fi
    case $usernameans in
    s)
    ;;
    *)
    username=$usernameans
    ;;
    esac
}

answerhost(){
clear
answer="
        hostname:

            s) - skip
            empty) - exit without save

"
printgraph
printanswer
read -p "         Your choice: " hostnameans
    if [ -z $hostnameans ]
    then
    choicexit
    fi
    case $hostnameans in
    s)
    ;;
    *)
    hostname=$hostnameans
    ;;
    esac
}

answerkernel(){
clear
answer='
        Choose kernel

            1) - linux
            2) - linux-zen
            3) - linux-lts
            any) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " kernelans
    case $kernelans in
    1)
    kernel=linux
    ;;
    2)
    kernel=linux-zen
    ;;
    3)
    kernel=linux-lts
    ;;
    *)
    choicexit
    ;;
    esac
}

answersystemadd(){
    case $system in
    BIOS)
    clear
    answer='
        Choose disk for grub ( /dev/sd* )

            s) - skip
            empty) - exit without save

    '
    printgraph
    printanswer
    lsblk
    echo " "
    read -p "         Your choice: " biosdiskans
        if [ -z "$biosdiskans" ]
        then
        choicexit
        fi
        case $biosdiskans in
        s)
        ;;
        *)
        biosdisk=$biosdiskans
        ;;
        esac
    ;;
    EFI)
    clear
    answer='
        Choos bootloader

            s) - skip
            d) - default (grub)
            empty) - exit without save

    '
    printgraph
    printanswer
    read -p "         Your choice: " efibootans
    echo " "
        if [ -z "$efibootans" ]
        then
        choicexit
        fi
        case $efibootans in
        s)
        ;;
        d)
        efiboot=grub
        ;;
        *)
        efiboot=$efibootans
        ;;
        esac
    ;;
    esac
}

answerdesktop(){
clear
answer='
        Choose a desktop environment

            (gnome, plasma, lxqt, lxde or another)
            s) - skip
            sk) if you already print, but want delete
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " desktopans
    if [ -z "$desktopans" ]
    then
    choicexit
    fi
    case $desktopans in
    s)
    ;;
    sk)
    desktop=
    ;;
    *)
    desktop=$desktopans
    ;;
    esac
}

answerdisplay(){
clear
answer='
        Choose a display manager

            (sddm, lightdm, gdm or another)
            s) - skip
            sk) if you already print, but want delete
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " displayans
    if [ -z "$displayans" ]
    then
    choicexit
    fi
    case $displayans in
    s)
    ;;
    sk)
    display=
    ;;
    *)
    display=$displayans
    ;;
    esac
}

answerextrapackages(){
clear
answer='
       Choose additional packages

            (nano, kate, falkon or another)
            s) - skip
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " extrapackagesans
    if [ -z $extrapackagesans ]
    then
    choicexit
    fi
    case $extrapackagesans in
    s)
    ;;
    sk)
    extrapackages=
    ;;
    *)
    extrapackages="$extrapackagesans"
    ;;
    esac
}

answerready(){
clear
answer='
       Are you sure?

         yes) - Proceed to install
         any) - retry
         empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " readyans
    if [ -z $readyans ]
    then
    choicexit
    fi
    if [ $readyans = yes ]
    then
    ready=1
    fi
}

answerpassroot(){
    clear
    correct=no
    answer="
       type root password
    "
    until [ $correct = yes ]
        do
        clear
        printanswer
        arch-chroot /mnt passwd
        read -p "Did you enter the pass correctly (yes/no)? : " correct
        done
}

answerpassuser(){
    clear
    correct=no
    answer="
       Type user password
    "
    arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $username
    echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers
    until [ $correct = yes ]
        do
        clear
        printanswer
        arch-chroot /mnt passwd $username
        read -p "Did you enter the pass correctly (yes/no)? : " correct
        done
}

answerending(){
    clear
    answer='
       Do you want reboot or...

         1)Enter livecd
         2)Enter arch-chroot (reboot after exit)
         any) - reboot
    '
    printanswer
    read -p "         Your choice: " endingans
    case $endingans in
        1)
        clear
        exit
        ;;
        2)
        clear
        arch-chroot /mnt
        umount -R /mnt
        reboot
        ;;
        *)
        clear
        umount -R /mnt
        reboot
        ;;
    esac
}


ready=0
while [ $ready = 0 ]
do
answersystem
answerpart
answerrootpart
answerbootpart
answerswappart
answerlocale
answertimezone
answeruser
answerhost
answerkernel
answersystemadd
answernetwork
answerdesktop
answerdisplay
answerextrapackages
answerready
done

if [ $ready = 1 ]
then

mkfs.ext4 /dev/$rootpart
mount /dev/$rootpart /mnt


if [ $system = EFI ]
then
	mkfs.fat -F32 /dev/$bootpart
	mkdir -p /mnt/boot/efi
	mount /dev/$bootpart /mnt/boot/efi
else
	mkfs.ext4 /dev/$bootpart
	mkdir /mnt/boot
	mount /dev/$bootpart /mnt/boot
fi

pacstrap /mnt base base-devel networkmanager $kernel $kernel-headers linux-firmware grub os-prober efibootmgr neovim

if [ -n "$desktop" ]
then
	pacstrap /mnt $desktop
fi

if [ -n "$display" ]
then
	pacstrap /mnt $display
fi

if [ -n "$extrapackages" ]
then
	pacstrap /mnt $extrapackages
fi

echo $hostname > /mnt/etc/hostname

echo "127.0.1.1 localhost.localdomain $hostname" >> /mnt/etc/hosts

echo LANG="$locale.UTF-8" > /mnt/etc/locale.conf
echo "LC_COLLATE="C"" >> /mnt/etc/locale.conf

echo $locale.UTF-8 UTF-8 >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
arch-chroot /mnt hwclock --systohc

case $system in
BIOS)
	arch-chroot /mnt grub-install --recheck $biosdisk
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
;;
EFI)
	arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=$efiboot
	arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
;;
esac
    
arch-chroot /mnt systemctl enable --now NetworkManager

if [ -n $display ]
then
	arch-chroot /mnt systemctl enable $display
fi

answerpassroot
answerpassuser
answerending

fi
