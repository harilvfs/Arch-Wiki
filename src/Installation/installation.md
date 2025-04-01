# Inside the ISO

- **Load Keyboard Layout** (Default: `usa`)
  *This command changes the keyboard layout for the console. For example, `de-latin1` is for a German layout. Use this if your keyboard differs from the default layout.*
  ```shell
  loadkeys de-latin1
  ```

- **List Your Drives**
  *Use this command to display all block devices (like hard drives), which helps you identify the target for installation.*
  ```shell
  lsblk
  ```

- **Wipe the Drive You Plan to Install On** (example: `nvme0n1` or `sda`)
  *Warning: This will erase all data on the specified drive! Use this command to start the process of partitioning.*
  ```shell
  gdisk /dev/nvme0n1
  ```
  - Press **"x"** for expert mode.  
  - Press **"z"** to wipe the drive and confirm with **"y"**.

- **Create Partitions on the Drive**
  *This command opens `cfdisk`, a user-friendly partition editor. Use the arrow keys to navigate, and the `Enter` key to create a new partition. You will define sizes for your partitions, like `1GiB` for the EFI boot partition.*
  ```shell
  cfdisk /dev/nvme0n1
  ```

  You usually want to create:
  1. **Boot Partition** (EFI)
  2. **Swap Partition**
  3. **System Partition**

  Your partitions should look like this:
  ```shell
  p1 = 1GiB, EFI
  p2 = 4GiB, Linux Swap
  p3 = ENTER, Linux Filesystem
  ```

- **Create Filesystems on These Partitions**:
  *These commands format the partitions so the system can use them.*
  - **Format the Boot Partition as FAT32**:
    ```shell
    mkfs.fat -F 32 /dev/nvme0n1p1
    ```
  - **Set Up the Swap Partition**:
    ```shell
    mkswap /dev/nvme0n1p2
    swapon /dev/nvme0n1p2
    ```
    *The `mkswap` command prepares the swap space, which helps manage memory. `swapon` activates it for immediate use.*
  - **Format the System Partition as EXT4**:
    ```shell
    mkfs.ext4 /dev/nvme0n1p3
    ```

- **Mount Your Partitions to Install Arch and a Bootloader**:
  *Mounting makes the partitions accessible to the installation process.*
  - **Mount the System Partition**:
    ```shell
    mount /dev/nvme0n1p3 /mnt
    ```
  - **Mount the Boot Partition**:
    ```shell
    mount --mkdir /dev/nvme0n1p1 /mnt/boot
    ```
    *The `--mkdir` option creates the mount point if it doesn't already exist.*

- **Now We Install Arch Linux**:
  *This command installs the essential packages for a basic Arch Linux system. It includes the kernel, base utilities, and a package manager.*
  ```shell
  pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware sof-firmware nano networkmanager grub efibootmgr intel-ucode bash-completion
  ```

- **Create the fstab File**:
  *This file tells the system which drives to mount at boot. Generating it now is crucial for the proper functioning of your new installation.*
  ```shell
  genfstab -U /mnt >> /mnt/etc/fstab
  ```
  *Note: The `>>` operator appends the output to the file, while `>` would overwrite it. This means any existing data in the file would be lost if `>` were used.*

- **Now We Are Ready to chroot Into Our New Install**:
  *`chroot` allows you to operate within your new system environment.*
  ```shell
  arch-chroot /mnt
  ```

---

# Inside the Install

- **Enable NetworkManager as a Service for Automatic Startup**:
  *This command ensures NetworkManager starts automatically at boot, managing your network connections.*
  ```shell
  systemctl enable NetworkManager
  ```

- **Edit the `pacman.conf` File for Important Changes**:
  *Open the package manager configuration file using `nano`, a simple text editor. You can navigate with the arrow keys and make edits.*
  ```shell
  nano /etc/pacman.conf
  ```
  - *Tip: Save changes with `CTRL + O`, exit with `CTRL + X`. To exit without saving, press `CTRL + X` and then `n` for no.*

  Add the following lines:
  ```ini
  [options]
  ILoveCandy
  ParallelDownloads = 5

  [multilib]
  include = /etc/pacman.d/mirrorlist
  ```
  *`ILoveCandy` adds a visual effect to downloads, and `ParallelDownloads` speeds up package retrieval by allowing multiple downloads simultaneously.*
  *`multilib` adds 32-Bit support which is crucial for some packages like `steam`.*

- **Update Pacman Repositories**:
  *This command refreshes the package database, ensuring you have the latest information about available packages.*
  ```shell
  pacman -Syy
  ```

- **Create a Symlink for Your Timezone**:
  *This command sets your system’s timezone, ensuring correct timekeeping.*
  ```shell
  ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  ```
  *Replace `Europe/Berlin` with your actual timezone.*

- **Sync the System Clock with Your BIOS Clock**:
  *This ensures the system clock is set to the correct time based on the hardware clock.*
  ```shell
  hwclock --systohc
  ```

- **Edit the `locale.gen` File to Generate Translations for the OS**:
  *This command opens the locale configuration file. Search for your desired locale and remove the `#` to uncomment it.*
  ```shell
  nano /etc/locale.gen
  ```
  - *Tip: Press `CTRL + W` to search in nano.*

- **Generate the Translations**:
  *Run this command to create the necessary language files for your system.*
  ```shell
  locale-gen
  ```

- **Edit the `locale.conf` File for System Language**:
  *This sets the default language for your system.*
  ```shell
  echo "LANG=de_DE.UTF-8" > /etc/locale.conf
  ```
  *Use `>` to create or overwrite the file.*

- **Set Your System Hostname**:
  *Choose a name that will identify your machine on the network.*
  ```shell
  echo "arch" > /etc/hostname
  ```

- **Change the Keyboard Layout for the Console**:
  *Set the layout for console sessions.*
  ```shell
  echo "KEYMAP=de-latin1" > /etc/vconsole.conf
  ```

- **Finally, Create Your Own User**:
  *This command creates a new user and assigns them to several groups for necessary permissions.*
  ```shell
  useradd -m -G wheel,power,storage,video,audio -s /bin/bash justus
  ```

- **Create a Password for Your User**:
  *Set a password for your new user account.*
  ```shell
  passwd justus
  ```

- **Edit the `sudoers` File**:
  *Allow your user to execute administrative commands. This step is important for system management.*
  ```shell
  EDITOR=nano visudo
  ```
  *Remove the `#` from `%wheel ALL=(ALL:ALL) ALL` to enable sudo access for your user.*

---

# Install the GRUB Bootloader

- **GRUB** is a reliable bootloader compatible with most hardware.
  
  *To install GRUB to the boot partition:*
  ```shell
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable
  ```
  *Explanation of arguments:*
  - `--target=x86_64-efi`: For 64-bit EFI systems; remove this for legacy BIOS.
  - `--efi-directory=/boot`: Specifies where to install GRUB.
  - `--bootloader-id=grub`: The name shown in the BIOS boot menu.
  - `--removable`: Recommended to prevent boot issues when changing BIOS settings.

- **Create the GRUB Config**:
  *This command generates the configuration file needed for GRUB to know what to load on boot.*
  ```shell
  grub-mkconfig -o /boot/grub/grub.cfg
  ```

- **Congratulations! You Installed Arch Linux the OCD Way!**  
  *Now you are ready to exit and reboot:*
  ```shell
  exit
  reboot
  ```
