# Touchpad

If your laptop's touchpad stops working such as touch input, gestures, or scrolling you can follow these steps to fix it.

Create the configuration file:

```sh
sudo touch /etc/X11/xorg.conf.d/30-touchpad.conf
```

You can edit it using `nano` or `vim`:

```sh
sudo vim /etc/X11/xorg.conf.d/30-touchpad.conf
```

Paste the following content into the file:

```sh
#/etc/X11/xorg.conf.d/30-touchpad.conf

Section "InputClass"
    Identifier "Touchpad"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
    Option "ScrollMethod" "twofinger"
    Option "MiddleEmulation" "true"
EndSection
```

After saving the file, reboot your system. The touchpad should now work properly.

This issue can occur occasionally, and defining this configuration manually often resolves it.
