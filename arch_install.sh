#!/bin/bash

blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)
white=$(tput sgr0)

clear
echo "${green}Welcome to my arch install script!${white}"

lsblk

echo "${green}Partitioning...${white}"

read -p "${blue}Which partition do you want for root? (sdx) ${white}" part
mkfs.ext4 /dev/$part
mount /dev/$part /mnt


read -p "${blue}Which partition do you want for boot? (sdx) ${white}" part
mkfs.fat -F32 /dev/$part
mkdir -p /mnt/boot/efi
mount /dev/$part /mnt/boot/efi

function swap(){
  read -p "${blue}Do you want a swap partition? (Y/N) ${white}" answer
  if [[ $answer == "Y"  || $answer == "Yes" || $answer == "y" || $answer == "yes" ]]
      then
    	  read -p "${blue}Which partition do you want for swap? (sdx) ${white}" part
    	  mkswap /dev/$part
		  swapon /dev/$part
  elif [[ $answer == "N"  || $answer == "No" || $answer == "n" || $answer == "no" ]]
	  then
		  echo "${green}There is nothing to do.${white}"
  else
	  echo "${red}Invalid option, redirecting...${white}"
	  swap()
  fi
}

echo "${green}Base install...${white}"

echo "${green}Installiing the kernel...${white}"

pacstrap /mnt base base-devel linux linux-firmware neovim networkmanager grub efibootmgr

echo "${green}Generating fstab file...${white}"

genfstab -U /mnt >> /mnt/etc/fstab

echo "${green}Enabling NetworkManager.service...${white}"

arch-chroot /mnt systemctl enable --now NetworkManager

read -p "${blue}Which drive do you want to install grub? (sdx) ${white}" drive

arch-chroot /mnt grub-install /dev/$drive

echo "${green}Configuring grub...${white}"

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo "${green}Making a new root password...${white}"

arch-chroot /mnt passwd

read -p "${blue}Hostname: ${white}" host

arch-chroot /mnt echo $host > /etc/hostname

echo "${green}I'm done, have fun with your brand new arch installation!${white}"
