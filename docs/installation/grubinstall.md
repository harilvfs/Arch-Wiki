# **Install the GRUB Bootloader**

> [!NOTE]  
> GRUB is a versatile and widely supported bootloader, making it an excellent choice for most systems.

### **1. Install GRUB to the Boot Partition**  
Use the following command to install GRUB: 

::: code-group

```bash [UEFI]
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub --removable
```

```bash [MBR BIOS (legacy boot)]
grub-install --target=i386-pc /dev/sdX
```

:::

> [!INFO] Explanation of Arguments [UEFI]
> - `--target=x86_64-efi`: Specifies the installation for 64-bit EFI systems. Omit this for legacy BIOS installations.  
> - `--efi-directory=/boot`: Indicates the directory where GRUB should be installed.  
> - `--bootloader-id=grub`: Sets the name of the bootloader as it appears in the BIOS boot menu.  
> - `--removable`: Ensures compatibility and prevents boot issues when BIOS settings are changed.


> [!INFO] Explanation of Arguments [MBR BIOS (legacy boot)]
> - **`grub-install`**: Installs the GRUB bootloader.
> - **`--target=i386-pc`**: Specifies the target for legacy BIOS (MBR) systems.
> - **`/dev/sdX`**: Replace `sdX` with your disk (e.g., `/dev/sda`). This installs GRUB to the disk’s MBR, not a partition.
---

### **2. Generate the GRUB Configuration File**  
> [!TIP]  
> This command creates the configuration file, enabling GRUB to manage and load operating systems.

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

---

### **3. Final Steps**  

**You’ve successfully installed GRUB and set up Arch Linux!**

<img src="https://cdn-icons-png.flaticon.com/128/190/190411.png" width="30" /> 

- Exit the chroot environment:  
  ```bash
  exit
  ```

- Unmount the partitions:  
  ```bash
  umount -R /mnt
  ```

- Reboot your system:  
  ```bash
  reboot
  ```

> [!NOTE]
> **Remember to remove the installation media (e.g., USB) after rebooting to avoid booting into the installer again.**


> [!IMPORTANT]
> I haven’t mentioned or written anything about installing graphics drivers for NVIDIA or AMD GPUs. You can find information for NVIDIA in these docs, but I strongly recommend checking the official [Arch Wiki](https://wiki.archlinux.org/title/Category:Graphics) for installing GPU drivers for both NVIDIA and AMD.
> 
> While I could include the documentation here for installing graphics drivers, it may not be the most effective way to properly set up your GPU drivers. Thank you.

