# Get sudo perms from user
echo "To run give sudo permissions..."
sudo echo "Permissions recieved..."

# Install Git as it will be needed for many tools
sudo pacman -Syu --noconfirm git

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
sudo pacman -Sy --noconfirm alsa-utils picom wezterm playerctl ripgrep the_silver_searcher pavucontrol rofi scrot i3lock maim xclip fd libfido2 ufw

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
sudo pacman -Sy --noconfirm noto-fonts-cjk wqy-zenhei otf-ipaexfont ttf-bakmuk
paru -Sy --noconfirm noto-fonts-emoji adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-droid ttf-iosevka

# paru deps
echo "-"
echo "-"
echo "-"
echo "###############################"
echo "# Installing deps from AUR... #"
echo "###############################"
paru -Sy --noconfirm diodon neovim-git fzf

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
echo "# Changing AwesomeWM to git version... #"
echo "########################################"
paru -Sy awesome-git
cd ~

# install nice window decorators
mkdir ~/.config/awesome
touch ~/.config/awesome/rc.lua
cd ~/.config/awesome
git clone https://github.com/mut-ex/awesome-wm-nice.git nice

# install themes
git clone --recurse-submodules --remote-submodules --depth 1 -j 2 https://github.com/lcpz/awesome-copycats.git
mv -bv awesome-copycats/* ~/.config/awesome; rm -rf awesome-copycats

# remove useless themes
cd themes
rm -rf blackburn
rm -rf copland
rm -rf holo
rm -rf multicolor
rm -rf powerarrow
rm -rf powerarrow-dark
rm -rf rainbow
rm -rf steamburn
rm -rf vertex

# make the template config the one in use for now
cd ..
cp rc.lua.template rc.lua

cd ~

# Install theme deps
sudo pacman -Sy --noconfirm amixer dmenu librewolf mpc mpd scrot unclutter xbacklight xsel slock rofi
sudo pacman -Sy --noconfirm lxappearance-gtk3 arc-gtk-theme
paru -Sy --noconfirm gtk2_prefs
paru -Sy --noconfirm bibata-cursor-theme-bin
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
paru -Sy --noconfirm brave-beta-bin deno
sudo pacman -Sy --noconfirm zsh
paru -Sy --noconfirm neofetch rbenv nvm
paru -Sy --noconfirm discord-ptb bat man-db man-pages openvpn slack-desktop solaar vlc nemo nemo-preview
paru -Sy --noconfirm exa ttf-firacode-nerd xorg-xinput
paru -Sy --noconfirm ferdium-bin arandr nvidia-settings

git clone --depth=1 https://github.com/savq/paq-nvim.git "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim

echo "-"
echo "-"
echo "-"
echo "########################"
echo "# Installing docker... #"
echo "########################"
paru -Sy --noconfirm docker docker-compose
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

