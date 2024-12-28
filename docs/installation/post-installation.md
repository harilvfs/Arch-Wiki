# **Post-Installation Setup**

### Enable NetworkManager as a Service  

> [!TIP]  
> Automatically starting NetworkManager ensures your network connections are managed without manual intervention at every boot.  


```bash
systemctl enable NetworkManager
```


### Configure `pacman.conf` for Optimized Package Management  

**[OPTIONAL]**

> [!NOTE]  
> Editing the `pacman.conf` file allows you to customize your package manager for better performance and features.

```bash
nano /etc/pacman.conf
```

- *Navigate with the arrow keys and make edits. Save changes with `CTRL + O`, exit with `CTRL + X`. To exit without saving, press `CTRL + X` and then `n`.*

Add the following lines to enhance functionality:
```bash [options]
ILoveCandy
ParallelDownloads = 5

[multilib]
include = /etc/pacman.d/mirrorlist
```

- `ILoveCandy`: Adds a fun visual effect to downloads.  
- `ParallelDownloads`: Speeds up package retrieval by enabling multiple simultaneous downloads.  
- `multilib`: Enables 32-bit support, essential for certain applications like `steam`.



### Update Pacman Repositories  

> [!TIP]  
> Refreshing the package database ensures access to the latest versions of available software.

```bash
pacman -Syy
```

---

### Set the System Timezone  

> [!IMPORTANT]  
> Choose the correct timezone to ensure accurate timekeeping. Replace `Asia/Kathmandu` with your actual timezone.
>
> **Press Tab to autocomplete the timezone.**

```bash
ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime
```

---

- **Sync the System Clock**  
> [!NOTE]  
> Synchronize your system clock with the BIOS clock to avoid timing discrepancies.

```bash
hwclock --systohc
```

---

- **Generate and Set Locale Configurations**  
> [!TIP]  
> Locale settings ensure the system uses the correct language and character encoding.

- Edit the `locale.gen` file to uncomment your desired locale:
   ```bash
   nano /etc/locale.gen
   ```
   - *Tip: Use `CTRL + W` to search for your locale.*

- Generate the locale:
   ```bash
   locale-gen
   ```

- Set the default system language:
    :::code-group
    ```bash [US English]
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    ```
    ```bash [CUSTOM]
    echo "LANG="Your Language.UTF-8" > /etc/locale.conf
    ```
    :::
   - Replace `en_US.UTF-8` with your preferred language.

---

### Set the Hostname  
> [!NOTE] 
> Your hostname identifies your system on a network.

```bash
echo "arch" > /etc/hostname
```

---

### Set Keyboard Layout for Console  
> [!TIP]  
> Configure the console keyboard layout to match your physical keyboard.

:::code-group

```bash [US Keyboard]
echo "KEYMAP=us" > /etc/vconsole.conf
```  
```bash [CUSTOM Keyboard]
echo "KEYMAP="Your Keyboard Layout"" > /etc/vconsole.conf
```
:::
- Replace `us` with your preferred keymap.

---

### Create a New User  
> [!IMPORTANT]  
> Add a non-root user with necessary permissions for a safer and more secure system.

```bash
useradd -m -G wheel,power,storage,video,audio -s /bin/bash yourusername
```

- Set a password for the new user:
  ```bash
  passwd yourusername
  ```

---

### Grant Sudo Access to the New User  
> [!CAUTION]  
> Modifying the `sudoers` file incorrectly can lock you out of administrative privileges. Be cautious!

1. Open the `sudoers` file:
   ```bash
   EDITOR=nano visudo
   ```

2. Uncomment the following line by removing the `#`:
   ```bash
   %wheel ALL=(ALL:ALL) ALL

This grants sudo access to all users in the `wheel` group.

