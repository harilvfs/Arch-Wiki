# Install a Desktop Environment

When installing a full desktop environment, most of them handle the audio server and other components automatically. Below is a brief guide to getting started with GNOME.

### Prerequisites

Before you begin, make sure your system is up to date:

```bash
sudo pacman -Syyu
```

### Required Packages

- **`gnome`**: This is the desktop environment itself.
- **`gnome-tweaks`**: A settings application for changing themes, fonts, cursors, and various other settings.
- **`gdm`**: The login manager (also called the window manager). This is the program where you enter your username and password and select the desktop environment.
- **`gst-libav`**: Provides multimedia codecs and enables video file previews in GNOME's file manager, Nautilus.

To install these packages, run the following command:

```bash
sudo pacman -S gnome gnome-tweaks gdm gst-libav
```

### Keyboard Layout

If you are using a non-US keyboard layout, it’s advisable to change it with the following command. Logging in with a non-functional layout can be quite challenging:

```bash
sudo localectl set-keymap de-latin1
```

### Enable the Display Manager

Next, enable the autostart for the login manager (GDM):

```bash
sudo systemctl enable gdm
```

### Reboot

You are now ready to reboot into your new desktop environment!

```bash
sudo reboot
```
