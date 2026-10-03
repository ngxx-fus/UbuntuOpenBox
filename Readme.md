# OpenBox WM Minimal & Snappy Setup

A minimal, performant, and responsive Openbox desktop environment on Ubuntu 24.04 LTS. Built with snappy GLX animations, Touchégg gesture navigation, Windows 10 style system indicators, and quadrant-docked utility windows.

---

## Prerequisites

Run the following installation steps sequentially to set up the shell, packages, dependencies, and window management tools.

### 1.1. Shell & Basic Utilities (Zsh & Oh-My-Zsh)

```bash
sudo apt update && sudo apt install -y git curl wget zsh plocate xdg-utils libgtk-3-bin
sh -c "$(curl -fsSL [https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh](https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh))" "" --unattended
git clone [https://github.com/zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions) ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
chsh -s $(which zsh)

```

### 1.2. Desktop Core Packages & Utilities

```bash
sudo apt update
sudo apt install -y \
    openbox obconf tint2 feh picom rofi \
    volumeicon-alsa network-manager-gnome \
    lxappearance arc-theme papirus-icon-theme \
    polybar alacritty copyq flameshot \
    pavucontrol bluez blueman upower brightnessctl \
    xdotool x11-utils libnotify-bin

```

### 1.3. Input Method (Fcitx5 Bamboo)

```bash
sudo apt purge -y ibus ibus-data
sudo apt install -y fcitx5 fcitx5-bamboo fcitx5-config-qt fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5

cat << 'EOF' >> ~/.xprofile
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
EOF

```

### 1.4. Fonts (Nerd Fonts & Material Design Glyphs)

```bash
sudo apt install -y fonts-jetbrains-mono fonts-font-awesome fonts-material-design-icons-iconfont
mkdir -p ~/.local/share/fonts
wget -P ~/.local/share/fonts [https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz)
tar -xf ~/.local/share/fonts/NerdFontsSymbolsOnly.tar.xz -C ~/.local/share/fonts/
rm ~/.local/share/fonts/NerdFontsSymbolsOnly.tar.xz
fc-cache -fv

```

### 1.5. Lockscreen (i3lock-color & Betterlockscreen)

```bash
# Build dependencies for i3lock-color
sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
    libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
    libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev \
    libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev

# Build & install i3lock-color
git clone [https://github.com/Raymo111/i3lock-color.git](https://github.com/Raymo111/i3lock-color.git) /tmp/i3lock-color
cd /tmp/i3lock-color && ./build.sh && sudo ./install-i3lock-color.sh
cd ~

# Install Betterlockscreen system executable
git clone [https://github.com/betterlockscreen/betterlockscreen.git](https://github.com/betterlockscreen/betterlockscreen.git) /tmp/betterlockscreen
cd /tmp/betterlockscreen && sudo ./install.sh system
cd ~

# Cache blurred lockscreen wallpaper
betterlockscreen -u ~/Pictures/Wallpapers/ -b 2.5

```

### 1.6. Expose & Window Switcher (Skippy-XD)

```bash
sudo apt install -y meson ninja-build libx11-dev libxft-dev libxrender-dev \
    libxcomposite-dev libxdamage-dev libxfixes-dev libxinerama-dev libpng-dev

git clone [https://github.com/felixfung/skippy-xd.git](https://github.com/felixfung/skippy-xd.git) /tmp/skippy-xd
cd /tmp/skippy-xd
meson setup build && ninja -C build && sudo ninja -C build install
mkdir -p ~/.config/skippy-xd
cp /tmp/skippy-xd/skippy-xd.rc ~/.config/skippy-xd/skippy-xd.rc
cd ~

```

### 1.7. Multi-touch Touchpad Gestures (Touchégg)

```bash
sudo add-apt-repository ppa:touchegg/stable -y
sudo apt update && sudo apt install -y touchegg
sudo systemctl enable --now touchegg.service

```

### 1.8. Standalone Super Key Mapping (xcape)

```bash
sudo apt update && sudo apt install -y xcape

```

---

## Configuration Paths

All dotfiles and operational configurations are organized in the following locations:

| Path | Description |
| --- | --- |
| `~/.config/openbox/autostart` | Session startup script (spawns Polybar, Picom, Fcitx5, xcape, daemons) |
| `~/.config/openbox/rc.xml` | Keybindings, focus policies, workspace rules, and quadrant window placement |
| `~/.config/openbox/polybar/config.ini` | Top status bar configuration with custom IPC click actions and Win10 indicators |
| `~/.config/polybar/scripts/bluetooth.sh` | Helper script checking Bluetooth device status, connected alias, and battery level |
| `~/.config/openbox/picom/picom.conf` | Fast GLX compositor setup, shadows, and low-latency fading animations |
| `~/.config/openbox/rofi/combi.rasi` | Custom unified application, window, and execution launcher theme ("Universe") |
| `~/.themes/Breeze-ob-custom/openbox-3/themerc` | Window border styling, titlebar buttons, and window frame metrics |
| `~/.config/touchegg/touchegg.conf` | Touchpad multi-finger gesture bindings (window switcher, workspaces, expose) |
| `~/.config/openbox/dunst/dunstrc` | Lightweight desktop notification styling and position rules |
| `~/.config/skippy-xd/skippy-xd.rc` | Appearance, layout, and activation settings for the Expose window switcher |
| `/etc/X11/xorg.conf.d/30-touchpad.conf` | Xorg driver configuration for touchpad tap-to-click and natural scrolling |
| `/etc/systemd/logind.conf` | System power key interception (`HandlePowerKey=ignore`) |
| `/etc/acpi/events/power-btn` | ACPI event definition redirecting the physical power button press |
| `/etc/acpi/power-btn-handler.sh` | ACPI hook triggering `~/.config/openbox/scripts/power` in the user X session |

---

## Keybindings & Shortcuts Reference

| Shortcut / Action | Command / Action | Description |
| --- | --- | --- |
| `Super` (Tap) | `xcape (Alt+Tab -> skippy-xd)` | Show all windows overview (like GNOME Activities) |
| `Alt + Space` | `rofi -show combi ... "Universe"` | Open Universe multi-mode launcher |
| `Super + d` | `ToggleShowDesktop` | Hide / Restore all active windows |
| `Super + x` / `Power Button` | `~/.config/openbox/scripts/power` | Open power and logout menu |
| `Super + r` | `alacritty` | Launch default terminal emulator |
| `Super + b` | `firefox` | Open web browser |
| `Super + v` | `copyq toggle` | Open clipboard manager history |
| `Super + l` | `betterlockscreen -l blur` | Lock screen with blurred wallpaper |
| `Super + Shift + s` | `flameshot gui` | Interactive screen region capture |
| `Alt + Tab` / `Super + Tab` | `skippy-xd --toggle --expose` | Window expose overview |
| `Super + Left / Right` | `MoveResizeTo (50% split)` | Snap window to left or right half-screen |
| `Super + Up` | `ToggleMaximize` | Toggle window maximization |
| `Super + Down` | `MoveToCenter (50% size)` | Restore and center floating window |
| `Super + Space` | `fcitx5-remote -t` | Toggle input engine (Vietnamese / English) |
| `Swipe 3 fingers (Left / Right)` | Touchégg | Switch virtual desktop workspaces |
| `Swipe 4 fingers (Up)` | Touchégg (`skippy-xd`) | Trigger expose overview mode |

---

## Misc Notes

* `openbox --reconfigure` : Reload Openbox keybindings and window placement rules.
* `polybar-msg cmd restart` : Reload Polybar configuration without logging out.
* `xprop WM_CLASS` : Click on any window to obtain its exact instance and class strings.
* `xwininfo -name "<Title>"` : Identify top-level window ID and geometry by window title.
* `pkill -USR1 -x sxhkd` : Reload custom shortcut daemons (if applicable).
* `betterlockscreen -u <path/to/wallpapers/> -b 2.5` : Regenerate cached lockscreen backgrounds.
