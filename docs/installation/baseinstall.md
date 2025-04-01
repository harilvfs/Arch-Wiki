# **Inside the ISO**

### **1. Load Keyboard Layout** (Default: `usa`)

> [!TIP]  
>If your keyboard layout is different from the default (USA), use the loadkeys command to switch to your preferred layout.
>
> For example, use loadkeys `us` for a US English keyboard.
:::code-group
```sh [US Keyboard]
loadkeys us
```
```sh [Custom Keyboard]
loadkeys "Your Keyboard Layout"
```
:::

---

### **2. List Your Drives**
> [!TIP]  
> Use the following command to identify all connected block devices (like hard drives or USB drives).  
> This is essential to ensure you're working on the correct drive.

```sh
lsblk
```

---

### **3. Wipe the Drive You Plan to Install On**  
> [!CAUTION]  
> This step will erase all data on the specified drive. Ensure you’ve backed up any important information before proceeding.

::: code-group
```bash [NVMe Drive]
gdisk /dev/nvme0n1
```

```bash [SATA Drive]
gdisk /dev/sda
```
:::

<strong>*Use your prefer drive*</strong>

- Press **"x"** for expert mode.  
- Press **"z"** to wipe the drive and confirm with **"y"**.

> [!TIP]  
> Double-check your drive identifier (`nvme0n1` or `sda`) using the `lsblk` command before proceeding to avoid data loss on the wrong drive.

---

### **4. Create Partitions on the Drive**
> [!NOTE]  
> Use the `cfdisk` command for a user-friendly partition editor. Use arrow keys to navigate and `Enter` to create a new partition.

::: code-group
```bash [NVMe Drive]
cfdisk /dev/nvme0n1
```

```bash [SATA Drive]
cfdisk /dev/sda
```
:::

::: code-group

```text [UEFI]
Create the following partitions:
- Boot Partition: EFI (1GiB)
- Swap Partition: 4GiB
- System Partition: Remaining space  
```

```text [MBR BIOS (legacy boot)]
Create the following partitions:
- Bios Boot Partition: BIOS (1MiB)
- Swap Partition: 4GiB
- System Partition: Remaining space  
```
:::

Your partitions should look like this:

::: code-group

```bash [UEFI]
p1 = 1GiB, EFI
p2 = 4GiB, Linux Swap
p3 = ENTER, Linux Filesystem
```

```bash [MBR BIOS (legacy boot)]
p1 = 1MiB, Bios Boot
p2 = 4GiB, Linux Swap
p3 = ENTER, Linux Filesystem
```
:::

---

### **5. Create Filesystems on These Partitions**

> [!NOTE]
> **If you are using an BIOS (legacy boot MBR), the EFI partition creation step is unnecessary and can be skipped.**
>
> ***I am using an asterisk ( * ) in the drive name **`(e.g., /dev/sda*)`** to indicate that you need to select your preferred partition, such as **`/dev/sda1`** or **`/dev/sda2`**. The same applies to NVMe drives, for example, **`/dev/nvme0n1p1`** or **`/dev/nvme0n1p2`**.***


- **Format the Boot Partition as FAT32:** [ Only For UEFI System ]

::: code-group
```bash [NVMe Drive]
mkfs.fat -F 32 /dev/nvme0n1p*
```

```bash [SATA Drive]
mkfs.fat -F 32 /dev/sda*
```
:::

- **Set Up the Swap Partition:**
::: code-group

```bash [NVMe Drive]
mkswap /dev/nvme0n1p*
swapon /dev/nvme0n1p*
```

```bash [SATA Drive]
mkswap /dev/sda*
swapon /dev/sda*
```
:::

> [!TIP]  
> The `mkswap` command prepares the swap space, and `swapon` activates it for immediate use.

- **Format the System Partition as EXT4:**

::: code-group

```bash [NVMe Drive]
mkfs.ext4 /dev/nvme0n1p*
```

```bash [SATA Drive]
mkfs.ext4 /dev/sda*
```
:::

---

### **6. Mount Your Partitions**
- **Mount the System Partition:**

::: code-group
```bash [NVMe Drive]
mount /dev/nvme0n1p* /mnt
```

```bash [SATA Drive]
mount /dev/sda* /mnt
```
:::

- **Mount the Boot Partition:** [ Only For UEFI System]

::: code-group
```bash [NVMe Drive]
mount --mkdir /dev/nvme0n1p* /mnt/boot
```

```bash [SATA Drive]
mount --mkdir /dev/sda* /mnt/boot
```
:::

> [!NOTE]  
> The `--mkdir` option creates the `/mnt/boot` directory if it doesn’t already exist.

---

### **7. Install Arch Linux**
> [!INFO]  
> This command installs the essential packages for a minimal Arch Linux system, including the kernel, firmware, and essential utilities.

> [!IMPORTANT]
> You will need to install `intel-ucode` for intel CPUs
> and `amd-ucode` for AMD CPUs for their microcode. These are important for stability, security and performance!

::: code-group

```bash [UEFI]
pacstrap -k /mnt base base-devel linux-zen linux-zen-headers linux-firmware sof-firmware nano networkmanager grub wget git efibootmgr intel-ucode bash-completion
```

```bash [MBR BIOS (legacy boot)]
pacstrap -k /mnt base base-devel linux-zen linux-zen-headers linux-firmware sof-firmware nano networkmanager grub wget git intel-ucode bash-completion
```

:::

---

### **8. Generate the fstab File**
> [!NOTE]  
> The `fstab` file tells the system which partitions to mount at boot.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

> [!TIP]  
> The `>>` operator appends the output to the file. Avoid using `>` unless you want to overwrite the file.

- **Explanation:**
  - `genfstab`: Generates `fstab` entries based on mounted partitions.
  - `-U`: Uses UUIDs to ensure consistency.
  - `/mnt`: Specifies the mount point of your installed system.
  - `>> /mnt/etc/fstab`: Appends entries to the `fstab` file. Using `>` will overwrite it.

- **How It Works:**
The `/mnt/etc/fstab` file will contain partition info, ensuring correct mounting during boot.

- **Verification:**
Check the `fstab` file with:

```bash
cat /mnt/etc/fstab
```

- **When to Re-run?** <img src="https://cdn-icons-png.flaticon.com/128/14865/14865151.png" width="40" />

**`Re-run if partitioning or mount points change.`**

---

### **9. Enter Your New System Environment**
> [!INFO]  
> The `arch-chroot` command changes your root directory to the new installation, allowing you to configure it further.

```bash
arch-chroot /mnt
```

