# Arch Linux Installation Notes

> [!NOTE]
> These are the base notes displayed at the top of the documentation.
>
> Only refer to them if you missed something in the earlier guide. 
>
> Avoid following these legacy notes directly.

## Preparation in the ISO Environment

1. **Set Keymap**  
   `loadkeys us`

2. **List Existing Partitions**  
   `lsblk`

3. **Partition Disk (Erase All)**  
   Use `gdisk` to prepare the disk:  
   `gdisk /dev/nvme0n1` or `gdisk /dev/sda`
   - Enter `x` to open expert mode  
   - Enter `z` to delete all partitions  

4. **Reboot System**  
   `reboot`

5. **Set Keymap Again**  
   `loadkeys us`

6. **List Partitions Again**  
   `lsblk`

7. **Create Partitions with cfdisk**  
   `cfdisk /dev/nvme0n1` or `cfdisk /dev/sda`

::: code-group

```text [UEFI]
   - Partition 1: `1G`, EFI  
   - Partition 2: `4G`, Linux swap  
   - Partition 3: Remaining space, Linux filesystem  
```

```text [MBR BIOS (legacy boot)]
   - Bios Boot Partition: BIOS (1MiB)
   - Swap Partition: 4GiB
   - System Partition: Remaining space
```

:::

8. **Format Partitions**  
   - `mkfs.fat -F 32 /dev/nvme0n1p*` or `mkfs.fat -F 32 /dev/sda*` [ Only For UEFI System] 
   - `mkswap /dev/nvme0n1p*`  or `mkswap /dev/sda*`
   - `swapon /dev/nvme0n1p*`  or `swapon /dev/sda*`
   - `mkfs.ext4 /dev/nvme0n1p*` or `mkfs.ext4 /dev/sda*`

9. **Mount Partitions**  
   - `mount /dev/nvme0n1p* /mnt`  or `mount /dev/sda* /mnt`
   - `mount --mkdir /dev/nvme0n1p* /mnt/boot`  or `mount --mkdir /dev/sda* /mnt/boot` [ Only For UEFI System]
   - `mount --mkdir /dev/sda* /mnt/media` or `mount --mkdir /dev/sda* /mnt/media` [ IDK ]

10. **Install Base System**  

::: code-group

```bash [UEFI]
pacstrap -k /mnt base base-devel linux linux-firmware sof-firmware linux-headers nano networkmanager grub efibootmgr intel-ucode bash-completion
```

```bash [MBR BIOS (legacy boot)]
pacstrap -k /mnt base base-devel linux-zen linux-zen-headers linux-firmware sof-firmware nano networkmanager grub wget git intel-ucode bash-completion
```

11. **Generate fstab**  
    `genfstab -U /mnt >> /mnt/etc/fstab`

12. **Chroot into New System**  
    `arch-chroot /mnt`

---

## Configuration in the New System

1. **Enable NetworkManager**  
   `sudo systemctl enable NetworkManager`

2. **Configure pacman**  [OPTIONAL]
   - `nano /etc/pacman.conf`  
     - Enable `ILoveCandy`, `ParallelDownloads`, and `Multilib`
   - **Update Package Database**  
      `pacman -Syy`

4. **Set Timezone**  
   `ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime` [Change `Asia/Kathmandu` to your timezone]

5. **Synchronize Hardware Clock**  
   `hwclock --systohc`

6. **Configure Locale**  
   - Edit locale file: `nano /etc/locale.gen`  
     - Uncomment `en_US.UTF-8`  [Change `en_US.UTF-8` to your locale]
   - Generate locale: `locale-gen`  
   - Set locale: `echo "LANG=en_US.UTF-8" > /etc/locale.conf` [Change `en_US.UTF-8` to your locale]

7. **Set Hostname**  
   `echo "arch" > /etc/hostname`

8. **Set Keymap**  
   `echo "KEYMAP=us" > /etc/vconsole.conf` [Change `us` to your keymap]

9. **Create User**  
   `useradd -m -g wheel,power,storage,video,audio -s /bin/bash yourusername`

10. **Set User Password**  
    `passwd yourusername`

11. **Edit sudoers File**  
    `EDITOR=nano visudo`  
    - Uncomment `%wheel ALL=(ALL) ALL`

---

## Additional Installations

### Nvidia Drivers
1. **Install Drivers**  
   `pacman -S nvidia-dkms libglvnd nvidia-utils opencl-nvidia nvidia-settings`

2. **Configure mkinitcpio**  
   - Edit configuration: `nano /etc/mkinitcpio.conf`  
     - Add `nvidia nvidia_modeset nvidia_uvm nvidia_drm` to `MODULES`

3. **Update Grub Configuration**  
   - Edit grub settings: `nano /etc/default/grub`  
     - Add `nvidia_drm.modeset=1` to `GRUB_CMDLINE_LINUX_DEFAULT`  
   - Rebuild initramfs: `mkinitcpio -P`

4. **Reboot System**

### GRUB Bootloader
1. **Install GRUB**  
::: code-group

```bash [UEFI]
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable
```

```bash [MBR BIOS (legacy boot)]
grub-install --target=i386-pc /dev/sdX
```

:::
2. **Generate GRUB Configuration**  
   `grub-mkconfig -o /boot/grub/grub.cfg`

3. **Exit Umount and Reboot**  
   `exit`  
   
   `umount -R /mnt`

   `reboot`

---

## PipeWire (Audio Server)

1. **Install PipeWire**  
   `sudo pacman -S lib32-pipewire pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse gst-plugin-pipewire wireplumber rtkit`

2. **Add User to rtkit Group**  
   `sudo usermod -a -G rtkit $USER`

3. **Enable PipeWire Services**  
   `systemctl --user enable pipewire pipewire-pulse wireplumber`

---

## Installing Desktop Environments (DE)

### GNOME
1. **Install GNOME and GDM**  
   `sudo pacman -S gnome gnome-tweaks gdm gst-libav`

2. **Set Keymap**  
   `sudo localectl set-keymap de-latin1`

3. **Enable GDM**  
   `sudo systemctl enable gdm`

4. **Reboot System**  
   `reboot`

### i3wm
1. **Clone Dotfiles Repo**  
   `git clone https://github.com/justus0405/i3wm-dotfiles.git`

2. **Navigate to Script Directory**  
   `cd i3wm-dotfiles/src/`

3. **Make Script Executable**  
   `chmod +x install.sh`

4. **Run Install Script**  
   `./install.sh`

### DWM
1. **Clone DWM Repo**  
   `git clone https://github.com/harilvfs/dwm`

2. **Install DWM**  
   `cd dwm`  
   `sudo make clean install`

### Hyprland
1. **Recommended Setup**  
   Use one of these repositories for a seamless setup:  
   - [Prasanth Rangan's Hyprdots](https://github.com/prasanthrangan/hyprdots)  
   - [ml4w's Hyprland Dotfiles](https://github.com/mylinuxforwork/dotfiles)  

   These repositories provide a ready-to-use Hyprland environment.

