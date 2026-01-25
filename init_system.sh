# Collect Git identity (used later)
read -rp "Git email: " GIT_USER_EMAIL
read -rp "Git user name: " GIT_USER_NAME

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
  echo "Git user name and email must not be empty."
  exit 1
fi

GIT_PRIVATE_CONFIG="$HOME/.private_profile.gitconfig"

cat > "$GIT_PRIVATE_CONFIG" <<EOF
[user]
  name = $GIT_USER_NAME
  email = $GIT_USER_EMAIL
EOF

chmod 600 "$GIT_PRIVATE_CONFIG"

# Get sudo perms from user
echo "To run give sudo permissions..."
sudo echo "Permissions recieved..."

# Install Git as it will be needed for many tools
sudo pacman -S --noconfirm git

# check for paru installation
if [ -d ~/packages/paru ]; then
	echo "Paru already installed"
else
	echo "Installing Paru..."
	cd ~
	mkdir ~/packages
	cd ~/packages
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si
  cd ~
fi

# install basic deps
echo "-"
echo "-"
echo "-"
echo "####################################"
echo "# Installing basic dependencies... #"
echo "####################################"
sudo pacman -S --noconfirm alsa-utils wezterm playerctl ripgrep the_silver_searcher pavucontrol rofi fd libfido2 ufw
sudo pacman -S --noconfirm gnome-keyring libsecret

# make sure things like slack and obs can access display through dbus
sudo pamcan -S --noconfirm xdg-desktop-portal-hyprland 

# make sure dunst is not installed so that mako is used instead
sudo pacman -Rns --noconfirm dunst

# enable firewall
echo "-"
echo "-"
echo "-"
echo "#######################"
echo "# Enable firewall... #"
echo "#######################"
sudo systemctl start ufw
sudo systemctl enable ufw
sudo ufw enable
echo "IPV6=yes" | sudo tee -a /etc/default/ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# install fonts
echo "-"
echo "-"
echo "-"
echo "#######################"
echo "# Installing fonts... #"
echo "#######################"
sudo pacman -S --noconfirm noto-fonts noto-fonts-cjk wqy-zenhei otf-ipaexfont ttf-bakmuk ttf-liberation
sudo pacman -S --noconfirm otf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd
paru -S --noconfirm noto-fonts-emoji adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-droid ttf-iosevka

# paru deps
echo "-"
echo "-"
echo "-"
echo "###############################"
echo "# Installing deps from AUR... #"
echo "###############################"
paru -S --noconfirm neovim-git fzf

echo "-"
echo "-"
echo "-"
echo "###################################"
echo "# Done installing dependencies... #"
echo "###################################"

echo "-"
echo "-"
echo "-"
echo "########################################"
echo "# Cursor theme... #"
echo "########################################"
paru -S --noconfirm bibata-cursor-theme-bin
ln --symbolic /usr/share/icons/Bibata-Original-Ice ~/.local/share/icons/default

sudo tee -a /etc/rofi.rasi > /dev/null <<EOT
configuration {
    kb-row-up: "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
    kb-row-down: "Down,Control+j";
    kb-accept-entry: "Control+m,Return,KP_Enter";
    terminal: "mate-terminal";
    kb-remove-to-eol: "Control+Shift+e";
    /*kb-mode-next: "Shift+Right,Control+Tab,Control+l";*/
    kb-mode-previous: "Shift+Left,Control+Shift+Tab,Control+h";
    kb-remove-char-back: "BackSpace";
}
EOT

echo "-"
echo "-"
echo "-"
echo "################################"
echo "# Installing tools and apps... #"
echo "################################"
sudo pacman -S --noconfirm zsh mako
paru -S --noconfirm zen-browser-bin deno
paru -S --noconfirm neofetch rbenv nvm ruby-build
paru -S --noconfirm discord-ptb bat man-db man-pages openvpn slack-desktop solaar vlc nemo nemo-preview
paru -S --noconfirm exa ttf-firacode-nerd xorg-xinput
paru -S --noconfirm ferdium-bin arandr nvidia-settings

git clone --depth=1 https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim

echo "-"
echo "-"
echo "-"
echo "########################"
echo "# Installing docker... #"
echo "########################"
paru -S --noconfirm docker docker-compose
sudo systemctl --now enable docker.service
sudo groupadd docker
sudo usermod -aG docker $USER

echo "-"
echo "-"
echo "-"
echo "########################"
echo "# Switching theme... #"
echo "########################"
mkdir -p ~/packages/ && cd ~/packages
git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
./autogen.sh --prefix=/usr
sudo make install
cd ~

echo "-"
echo "-"
echo "-"
echo "###############################"
echo "# Full update just in case... #"
echo "###############################"
paru -Syu


echo "-"
echo "-"
echo "-"
echo "#####################"
echo "# Installing ZSH... #"
echo "#####################"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

