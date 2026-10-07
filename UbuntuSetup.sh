#!/usr/bin/env bash

################################################################################################
# ABOUT
#    This script was created to init OpenBox, Xorg from Ubuntu (server)
#    Integrated with Neovim, Zsh, Clangd, Howdy, and other custom utilities.
################################################################################################

################################################################################################
# CONFIG | SECTION ENABLE
#    This config section contains list of YES/NO (YES=1, NO=0) selection to decide which
#    will be installed.
#    User can easierly choose what will be install
################################################################################################

CONF_INSTALL_CUSTOM_APP_EN=1
CONF_INSTALL_ZSH_EN=1
CONF_INSTALL_OMZ_EN=1
CONF_INSTALL_NVIM_EN=1
CONF_INSTALL_NERD_FONT_EN=1
CONF_INSTALL_XORG_EN=1
CONF_INSTALL_OPENBOX_EN=1
CONF_INSTALL_POLYBAR_EN=1
CONF_INSTALL_FCITX5_BAMBOO_EN=1
CONF_INSTALL_LOCKSCREEN_EN=1
CONF_INSTALL_SKIPPY_XD_EN=1
CONF_INSTALL_TOUCHEGG_EN=1
CONF_INSTALL_XCAPE_EN=1
CONF_INSTALL_USER_ALIASES_EN=1
CONF_INSTALL_BACKGROUND_EN=1
CONF_INSTALL_CLANGD_EN=1
CONF_INSTALL_HOWDY_EN=1

# Use bash array for custom apps
CONF_CUSTOM_APP_LIST=(
    "wget" "curl" "htop" "neofetch" "btop" "tree" "duf" "tmux" "git" "plocate" "xdg-utils" "libgtk-3-bin" "chromium"
)

################################################################################################
# CONFIG | SYSTEM
#    This config section contains list of dir paths/file paths/urls which will be used in this
#    script.
#    User only need to change anything in this section if only this script is goes wrong.
################################################################################################

# Variables for Paths
FOLDER_CURRENT=$(pwd)
FOLDER_HOME="${HOME}"
FOLDER_DOWNLOADS="${FOLDER_HOME}/Downloads"
FOLDER_FUS="${FOLDER_HOME}/.fus"
FOLDER_BACKGROUND="${FOLDER_FUS}/.BG"
FOLDER_DOT_ZSHRC="${FOLDER_HOME}/.zshrc"
FOLDER_XPROFILE="${FOLDER_HOME}/.xprofile"
FOLDER_DOT_OH_MY_ZSH="${FOLDER_HOME}/.oh-my-zsh"
FOLDER_NVIM_CONFIG="${FOLDER_HOME}/.config/nvim"
FOLDER_CLANGD="/opt/clangd"
FILE_USER_ALIASES="${FOLDER_FUS}/user_aliases.sh"

# Variables for URLs
URL_FORWORK_ROOTDIR="https://raw.githubusercontent.com/ngxx-fus/ForWork/refs/heads/main"
URL_USER_ALIASES="${URL_FORWORK_ROOTDIR}/.assert/useralias.sh"
URL_NGXXFUS_THEME="${URL_FORWORK_ROOTDIR}/.assert/ngxxfus.zsh-theme"
URL_BACKGROUND_IMG="${URL_FORWORK_ROOTDIR}/.imgs/BG/IMG_4273.JPG"
URL_NVIM_DOWNLOAD="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz"
URL_NEOVIM_CONF_REPO="https://github.com/ngxx-fus/neovim-conf.git"
URL_OHMYZSH_INSTALL_SCRIPT="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
URL_NERDFONTS="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz"
URL_CLANGD="https://github.com/clangd/clangd/releases/download/22.1.6/clangd-linux-22.1.6.zip"

# Required OpenBox config directories based on PathLists.txt
OPENBOX_DIR_LIST=(
    "${FOLDER_HOME}/.config/openbox"
    "${FOLDER_HOME}/.config/openbox/autostart"
    "${FOLDER_HOME}/.config/openbox/polybar"
    "${FOLDER_HOME}/.config/openbox/picom"
    "${FOLDER_HOME}/.config/openbox/rofi"
    "${FOLDER_HOME}/.config/openbox/scripts"
    "${FOLDER_HOME}/.config/openbox/dunst"
    "${FOLDER_HOME}/.config/openbox/wallpaper"
    "${FOLDER_HOME}/.config/polybar/scripts"
    "${FOLDER_HOME}/.themes/Breeze-ob-custom/openbox-3"
    "${FOLDER_HOME}/.config/touchegg"
    "${FOLDER_HOME}/.config/skippy-xd"
    "${FOLDER_HOME}/.config/Thunar"
)

################################################################################################
# UTILS
################################################################################################

GLOBAL_STEP=0
SUB_STEP=0
declare -a ERROR_LIST

# @brief Starts a major tracking step.
# @param step_name Name of the major step.
StartMajorStep() {
    GLOBAL_STEP=$((GLOBAL_STEP + 1))
    SUB_STEP=0
    echo ""
    echo ">>> ${GLOBAL_STEP}. ${1}"
}

# @brief Starts a minor tracking step.
# @param step_name Name of the sub step.
StartSubStep() {
    SUB_STEP=$((SUB_STEP + 1))
    echo ">>> ${GLOBAL_STEP}.${SUB_STEP}. ${1}"
}

# @brief Records an error into the global error array.
# @param err_msg The error message to record.
RecordError() {
    ERROR_LIST+=("Step ${GLOBAL_STEP}.${SUB_STEP}: ${1}")
    echo "[ERR] ${1} ---> Skipped"
}

# @brief Checks if a remote URL is reachable.
# @param target_url The URL to verify.
# @return 0 on success, 1 on failure.
CheckURL() {
    local target_url="$1"
    # Check curl execution result
    if curl --output /dev/null --silent --head --fail --location "${target_url}"; then
        # Exit success
        return 0
    else
        # Exit failure
        return 1
    fi
}

# @brief Ensures the specified directory exists.
# @param target_dir Path to the directory.
# @return 0 on success, 1 on failure.
MakeThisDirExist() {
    # Check argument count
    if [[ $# -ne 1 ]]; then
        # Exit failure
        return 1
    fi
    local target_dir="$1"
    
    # Check if directory already exists
    if [ -d "${target_dir}" ]; then
        # Exit success
        return 0
    fi
    
    # Execute directory creation and evaluate
    if mkdir -p "${target_dir}"; then
        # Exit success
        return 0
    else
        # Exit failure
        return 1
    fi
}

# @brief Appends a string to a file if it doesn't already exist.
# @param target_file The file to edit.
# @param line The string to append.
AppendIfNotExist() {
    local target_file="$1"
    local line="$2"
    # Check if target file is missing
    if [ ! -f "${target_file}" ]; then
        touch "${target_file}"
    fi
    # Evaluate if line already exists in file
    if ! grep -qF "${line}" "${target_file}" 2>/dev/null; then
        echo "${line}" >> "${target_file}"
    fi
}

################################################################################################
# ACTIONS
################################################################################################

# @brief Installs custom APT applications.
Action_Install_CustomApp() {
    # Check config enable
    if [ "${CONF_INSTALL_CUSTOM_APP_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Custom APT Packages"
    
    sudo apt update -y >/dev/null 2>&1
    # Iterate over custom app list
    for app in "${CONF_CUSTOM_APP_LIST[@]}"; do
        StartSubStep "Install ${app}"
        sudo DEBIAN_FRONTEND=noninteractive apt install -y "${app}" >/dev/null 2>&1 || RecordError "Failed to install ${app}"
    done
    # Exit action
    return 0
}

# @brief Installs core ZSH packages.
Action_Install_Zsh() {
    # Check config enable
    if [ "${CONF_INSTALL_ZSH_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install ZSH Shell"
    StartSubStep "Run apt install zsh"
    sudo DEBIAN_FRONTEND=noninteractive apt install -y zsh >/dev/null 2>&1 || RecordError "Failed to install ZSH via apt"
    
    StartSubStep "Change default shell"
    # Evaluate shell change
    if command -v zsh >/dev/null 2>&1; then
        sudo chsh -s "$(which zsh)" "${USER}" || RecordError "Failed to change shell"
    else
        RecordError "ZSH is not installed properly"
    fi
    # Exit action
    return 0
}

# @brief Installs Oh-My-Zsh and custom plugins.
Action_Install_OMZ() {
    # Check config enable
    if [ "${CONF_INSTALL_OMZ_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Oh-My-Zsh & Theme"
    
    StartSubStep "Check OMZ Installer URL"
    # Verify connectivity
    if ! CheckURL "${URL_OHMYZSH_INSTALL_SCRIPT}"; then
        RecordError "Cannot reach OMZ script URL"
        # Terminate early
        return 1
    fi
    
    StartSubStep "Execute OMZ installation"
    # Backup existing OMZ installation
    if [ -d "${FOLDER_DOT_OH_MY_ZSH}" ]; then
        mv "${FOLDER_DOT_OH_MY_ZSH}" "${FOLDER_DOT_OH_MY_ZSH}.bak.$(date +%s)"
    fi
    sh -c "$(curl -fsSL ${URL_OHMYZSH_INSTALL_SCRIPT})" "" --unattended >/dev/null 2>&1 || true
    
    StartSubStep "Clone Zsh plugins"
    local zsh_custom="${FOLDER_DOT_OH_MY_ZSH}/custom"
    # Check OMZ custom directory
    if [ -d "${zsh_custom}" ]; then
        git clone https://github.com/zsh-users/zsh-completions "${zsh_custom}/plugins/zsh-completions" >/dev/null 2>&1 || RecordError "Failed zsh-completions"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting" >/dev/null 2>&1 || RecordError "Failed syntax-highlighting"
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "${zsh_custom}/plugins/zsh-autosuggestions" >/dev/null 2>&1 || RecordError "Failed autosuggestions"
        git clone https://github.com/agkozak/zsh-z.git "${zsh_custom}/plugins/zsh-z" >/dev/null 2>&1 || RecordError "Failed zsh-z"
        
        # Modify plugins list in zshrc safely
        sed -i 's/^plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-z)/' "${FOLDER_DOT_ZSHRC}" || RecordError "Failed to update plugins in .zshrc"
    else
        RecordError "Oh-My-Zsh custom directory missing"
    fi
    
    StartSubStep "Download ngxxfus theme"
    # Verify theme URL
    if CheckURL "${URL_NGXXFUS_THEME}"; then
        MakeThisDirExist "${FOLDER_DOT_OH_MY_ZSH}/themes"
        wget -q -O "${FOLDER_DOT_OH_MY_ZSH}/themes/ngxxfus.zsh-theme" "${URL_NGXXFUS_THEME}"
        # Set theme in zshrc
        if grep -q '^ZSH_THEME=' "${FOLDER_DOT_ZSHRC}"; then
            sed -i 's/^ZSH_THEME=.*/ZSH_THEME="ngxxfus"/' "${FOLDER_DOT_ZSHRC}"
        else
            AppendIfNotExist "${FOLDER_DOT_ZSHRC}" 'ZSH_THEME="ngxxfus"'
        fi
    else
        RecordError "Failed to reach theme URL"
    fi
    # Exit action
    return 0
}

# @brief Installs Neovim from pre-compiled tarball.
Action_Install_Nvim() {
    # Check config enable
    if [ "${CONF_INSTALL_NVIM_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Neovim & Prerequisites"
    
    StartSubStep "Install Nvim Prerequisites"
    sudo apt install -y build-essential gcc g++ make ripgrep fd-find unzip tar nodejs npm python3 python3-pip xclip wl-clipboard >/dev/null 2>&1 || RecordError "Failed to install Nvim prereqs"
    
    StartSubStep "Check Nvim URL"
    # Check connectivity
    if ! CheckURL "${URL_NVIM_DOWNLOAD}"; then
        RecordError "Nvim download URL unreachable"
        # Break execution
        return 1
    fi
    
    StartSubStep "Download & Extract Nvim"
    MakeThisDirExist "${FOLDER_DOWNLOADS}"
    # Change directory safely
    cd "${FOLDER_DOWNLOADS}" || return 1
    wget -q "${URL_NVIM_DOWNLOAD}" -O nvim-linux64.tar.gz
    
    # Check archive existence
    if [ -f "nvim-linux64.tar.gz" ]; then
        tar -zxf nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim
        sudo mkdir -p /opt/nvim
        sudo cp -r nvim-linux-x86_64/* /opt/nvim/
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    else
        RecordError "Nvim archive missing after download"
    fi
    
    StartSubStep "Clone Custom Neovim Config"
    # Backup existing neovim config
    if [ -d "${FOLDER_NVIM_CONFIG}" ]; then
        mv "${FOLDER_NVIM_CONFIG}" "${FOLDER_NVIM_CONFIG}.bak.$(date +%s)"
    fi
    git clone --recurse-submodules "${URL_NEOVIM_CONF_REPO}" "${FOLDER_NVIM_CONFIG}" >/dev/null 2>&1 || RecordError "Failed to clone neovim config"

    # Return to original directory
    cd "${FOLDER_CURRENT}" || return 1
    # Exit action
    return 0
}

# @brief Installs Nerd Fonts.
Action_Install_NerdFont() {
    # Check config enable
    if [ "${CONF_INSTALL_NERD_FONT_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Nerd & System Fonts"
    
    StartSubStep "Install System Fonts via Apt"
    sudo apt install -y fonts-jetbrains-mono fonts-font-awesome fonts-material-design-icons-iconfont >/dev/null 2>&1 || RecordError "Failed system fonts"

    StartSubStep "Check NerdFont URL"
    # Verify font URL
    if ! CheckURL "${URL_NERDFONTS}"; then
        RecordError "Font download URL unreachable"
        # Terminate
        return 1
    fi
    
    StartSubStep "Download and cache fonts"
    MakeThisDirExist "${FOLDER_HOME}/.local/share/fonts"
    wget -q -P "${FOLDER_HOME}/.local/share/fonts" "${URL_NERDFONTS}"
    
    local font_archive="${FOLDER_HOME}/.local/share/fonts/NerdFontsSymbolsOnly.tar.xz"
    # Check if font file exists
    if [ -f "${font_archive}" ]; then
        tar -xf "${font_archive}" -C "${FOLDER_HOME}/.local/share/fonts/"
        rm -f "${font_archive}"
        fc-cache -fv >/dev/null 2>&1
    else
        RecordError "Failed to locate font archive"
    fi
    # Exit action
    return 0
}

# @brief Installs base XORG components.
Action_Install_Xorg() {
    # Check config enable
    if [ "${CONF_INSTALL_XORG_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Core Xorg utilities"
    StartSubStep "Apt install xorg apps"
    sudo apt install -y picom rofi volumeicon-alsa network-manager-gnome pamixer \
        gnome-terminal copyq flameshot pavucontrol bluez blueman upower brightnessctl \
        xdotool x11-utils libnotify-bin >/dev/null 2>&1 || RecordError "Xorg utilities install failed"
    # Exit action
    return 0
}

# @brief Installs OpenBox WM and prepares configuration layout.
Action_Install_OpenBox() {
    # Check config enable
    if [ "${CONF_INSTALL_OPENBOX_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install OpenBox WM"
    StartSubStep "Apt install openbox & themes"
    sudo apt install -y openbox obconf tint2 feh lxappearance arc-theme papirus-icon-theme thunar >/dev/null 2>&1 || RecordError "OpenBox packages install failed"
    
    StartSubStep "Create configuration directories"
    # Iterate over openbox dir list
    for dir in "${OPENBOX_DIR_LIST[@]}"; do
        MakeThisDirExist "${dir}"
    done
    # Exit action
    return 0
}

# @brief Installs Polybar.
Action_Install_Polybar() {
    # Check config enable
    if [ "${CONF_INSTALL_POLYBAR_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Polybar"
    StartSubStep "Apt install polybar"
    sudo apt install -y polybar >/dev/null 2>&1 || RecordError "Polybar install failed"
    # Exit action
    return 0
}

# @brief Installs Fcitx5 Bamboo for input.
Action_Install_Fcitx5Bamboo() {
    # Check config enable
    if [ "${CONF_INSTALL_FCITX5_BAMBOO_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Fcitx5 Bamboo"
    StartSubStep "Purge old ibus"
    sudo apt purge -y ibus ibus-data >/dev/null 2>&1 || true
    
    StartSubStep "Apt install fcitx5"
    sudo apt install -y fcitx5 fcitx5-bamboo fcitx5-config-qt fcitx5-frontend-gtk2 fcitx5-frontend-gtk3 fcitx5-frontend-gtk4 fcitx5-frontend-qt5 >/dev/null 2>&1 || RecordError "Fcitx5 install failed"
    
    StartSubStep "Set Profile Environments"
    AppendIfNotExist "${FOLDER_XPROFILE}" "export GTK_IM_MODULE=fcitx"
    AppendIfNotExist "${FOLDER_XPROFILE}" "export QT_IM_MODULE=fcitx"
    AppendIfNotExist "${FOLDER_XPROFILE}" "export XMODIFIERS=@im=fcitx"
    # Exit action
    return 0
}

# @brief Installs Betterlockscreen & dependencies.
Action_Install_Lockscreen() {
    # Check config enable
    if [ "${CONF_INSTALL_LOCKSCREEN_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Lockscreen Utilities"
    StartSubStep "Install dependencies"
    sudo apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev >/dev/null 2>&1 || RecordError "Lockscreen Dependencies install failed"
    
    StartSubStep "Clone & build i3lock-color"
    rm -rf /tmp/i3lock-color
    git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color >/dev/null 2>&1 || RecordError "Clone i3lock failed"
    # Check if tmp dir exists
    if [ -d "/tmp/i3lock-color" ]; then
        cd /tmp/i3lock-color || return 1
        ./build.sh >/dev/null 2>&1
        sudo ./install-i3lock-color.sh >/dev/null 2>&1
        cd "${FOLDER_CURRENT}" || return 1
    fi
    
    StartSubStep "Clone & build betterlockscreen"
    rm -rf /tmp/betterlockscreen
    git clone https://github.com/betterlockscreen/betterlockscreen.git /tmp/betterlockscreen >/dev/null 2>&1 || RecordError "Clone betterlockscreen failed"
    # Check if tmp dir exists
    if [ -d "/tmp/betterlockscreen" ]; then
        cd /tmp/betterlockscreen || return 1
        sudo ./install.sh system >/dev/null 2>&1
        cd "${FOLDER_CURRENT}" || return 1
    fi
    # Exit action
    return 0
}

# @brief Installs Skippy-XD.
Action_Install_SkippyXD() {
    # Check config enable
    if [ "${CONF_INSTALL_SKIPPY_XD_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Skippy-XD"
    StartSubStep "Install deps"
    sudo apt install -y meson ninja-build libx11-dev libxft-dev libxrender-dev libxcomposite-dev libxdamage-dev libxfixes-dev libxinerama-dev libpng-dev >/dev/null 2>&1 || RecordError "Skippy dependencies failed"
    
    StartSubStep "Build Skippy-XD"
    rm -rf /tmp/skippy-xd
    git clone https://github.com/felixfung/skippy-xd.git /tmp/skippy-xd >/dev/null 2>&1 || RecordError "Clone Skippy failed"
    # Check if dir exists
    if [ -d "/tmp/skippy-xd" ]; then
        cd /tmp/skippy-xd || return 1
        meson setup build >/dev/null 2>&1
        ninja -C build >/dev/null 2>&1
        sudo ninja -C build install >/dev/null 2>&1
        MakeThisDirExist "${FOLDER_HOME}/.config/skippy-xd"
        cp /tmp/skippy-xd/skippy-xd.rc "${FOLDER_HOME}/.config/skippy-xd/skippy-xd.rc" 2>/dev/null || true
        cd "${FOLDER_CURRENT}" || return 1
    fi
    # Exit action
    return 0
}

# @brief Installs Touchegg daemon.
Action_Install_Touchegg() {
    # Check config enable
    if [ "${CONF_INSTALL_TOUCHEGG_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Touchegg"
    StartSubStep "Add repo and install"
    sudo add-apt-repository ppa:touchegg/stable -y >/dev/null 2>&1
    sudo apt update >/dev/null 2>&1
    sudo apt install -y touchegg >/dev/null 2>&1 || RecordError "Touchegg install failed"
    sudo systemctl enable --now touchegg.service >/dev/null 2>&1 || true
    # Exit action
    return 0
}

# @brief Installs Xcape keybinder.
Action_Install_Xcape() {
    # Check config enable
    if [ "${CONF_INSTALL_XCAPE_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Xcape"
    StartSubStep "Apt install xcape"
    sudo apt update >/dev/null 2>&1
    sudo apt install -y xcape >/dev/null 2>&1 || RecordError "Xcape install failed"
    # Exit action
    return 0
}

# @brief Installs User Aliases.
Action_Install_Aliases() {
    # Check config enable
    if [ "${CONF_INSTALL_USER_ALIASES_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install User Aliases"
    MakeThisDirExist "${FOLDER_FUS}"
    
    StartSubStep "Verify & Download Aliases"
    # Verify URL connection
    if CheckURL "${URL_USER_ALIASES}"; then
        wget -q -O "${FILE_USER_ALIASES}" "${URL_USER_ALIASES}"
        chmod +x "${FILE_USER_ALIASES}"
        AppendIfNotExist "${FOLDER_DOT_ZSHRC}" "# User aliases"
        AppendIfNotExist "${FOLDER_DOT_ZSHRC}" "source ${FILE_USER_ALIASES}"
    else
        RecordError "Alias URL unreachable"
    fi
    # Exit action
    return 0
}

# @brief Setups Desktop Background.
Action_Install_Background() {
    # Check config enable
    if [ "${CONF_INSTALL_BACKGROUND_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Setup Desktop Background"
    MakeThisDirExist "${FOLDER_BACKGROUND}"
    
    StartSubStep "Download & Store Background Image"
    # Verify connection
    if CheckURL "${URL_BACKGROUND_IMG}"; then
        local dest_img="${FOLDER_BACKGROUND}/BG_IMG.jpg"
        wget -q -O "${dest_img}" "${URL_BACKGROUND_IMG}"
        # Validate downloaded file
        if [ ! -f "${dest_img}" ]; then
            RecordError "Failed to write background image"
        else
            sudo mkdir -p "/usr/share/backgrounds/xfce"
            sudo cp -f "${dest_img}" "/usr/share/backgrounds/xfce/BG_IMG.jpg" 2>/dev/null || true
            sudo chmod 644 "/usr/share/backgrounds/xfce/BG_IMG.jpg" 2>/dev/null || true
        fi
    else
        RecordError "Background URL unreachable"
    fi
    # Exit action
    return 0
}

# @brief Installs Clangd language server.
Action_Install_Clangd() {
    # Check config enable
    if [ "${CONF_INSTALL_CLANGD_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Clangd"
    MakeThisDirExist "${FOLDER_DOWNLOADS}"
    
    StartSubStep "Check & Download Clangd URL"
    # Verify connection
    if CheckURL "${URL_CLANGD}"; then
        cd "${FOLDER_DOWNLOADS}" || return 1
        wget -q -O clangd.zip "${URL_CLANGD}"
        # Check archive existence
        if [ -f "clangd.zip" ]; then
            unzip -q clangd.zip
            sudo rm -rf "${FOLDER_CLANGD}"
            sudo mv clangd_22.1.6 "${FOLDER_CLANGD}"
            sudo ln -sf "${FOLDER_CLANGD}/bin/clangd" /usr/bin/clangd
            rm -f clangd.zip
        else
            RecordError "Clangd zip missing"
        fi
        cd "${FOLDER_CURRENT}" || return 1
    else
        RecordError "Clangd URL unreachable"
    fi
    # Exit action
    return 0
}

# @brief Installs Howdy for biometric authentication.
Action_Install_Howdy() {
    # Check config enable
    if [ "${CONF_INSTALL_HOWDY_EN}" -ne 1 ]; then
        # Bypass
        return 0
    fi
    StartMajorStep "Install Howdy"
    StartSubStep "Add Howdy PPA & Install"
    
    # Add apt repository
    sudo add-apt-repository ppa:boltgolt/howdy -y >/dev/null 2>&1 || RecordError "Failed to add Howdy PPA"
    # Update local repos
    sudo apt update >/dev/null 2>&1
    # Trigger non-interactive installation
    sudo DEBIAN_FRONTEND=noninteractive apt install -y howdy >/dev/null 2>&1 || RecordError "Howdy install failed"
    
    # Exit action
    return 0
}

################################################################################################
# MAIN
################################################################################################

echo "================================================================================"
echo "                   UBUNTU OPENBOX CONFIGURATION SCRIPT START                    "
echo "================================================================================"

Action_Install_CustomApp
Action_Install_Zsh
Action_Install_OMZ
Action_Install_Nvim
Action_Install_NerdFont
Action_Install_Xorg
Action_Install_OpenBox
Action_Install_Polybar
Action_Install_Fcitx5Bamboo
Action_Install_Lockscreen
Action_Install_SkippyXD
Action_Install_Touchegg
Action_Install_Xcape
Action_Install_Aliases
Action_Install_Background
Action_Install_Clangd
Action_Install_Howdy

echo ""
echo "================================================================================"
echo "                                SUMMARY REPORT                                  "
echo "================================================================================"

# Check if any errors occurred
if [ ${#ERROR_LIST[@]} -eq 0 ]; then
    echo "[SUCCESS] All selected modules have been installed without errors!"
else
    echo "[WARNING] The following errors were encountered during execution:"
    # Loop over tracked errors
    for err in "${ERROR_LIST[@]}"; do
        echo "  - ${err}"
    done
fi
echo "================================================================================"
# Terminate script execution
exit 0
