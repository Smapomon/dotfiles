# ARCH XORG AWESOME
## INSTALLATION PROCESS:

1. navigate to /etc/pacman.conf and uncomment and add jack2 to IgnorePKG =
2. install staring packages with pacman
	- git
	- neovim
	- vim
	- firefox (this will be the backup browser, eventually we will change to brave)
	- kitty (default terminal)
	- less
    - scrot
    - i3lock
    - solaar
    - xorg-xinput
    - nvidia-settings
    - arandr
    - rofi

3. install PARU the AUR helper
	mkdir -p ~/packages
	cd ~/packages
	sudo pacman -S --needed base-devel (this should likely be already installed)
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si

4. install packages with paru:
	- brave-bin
	- 1password
	- slack-desktop
    - diodon
    - discord-ptb
    - ferdium-bin

5. install fonts:
    - ttf-twemoji (AUR)
    - ttf-joypixels
    - noto-fonts-emoji
    - noto-fonts-cjk
    - ttf-iosevka
    - ttf-meslo-nerd-font-powerlevel10k

6. setup slack, 1pass, brave

7. setup zsh, oh-my-zsh, p10k
	- sudo pacman -S zsh zsh-completions
	- zsh
	- chsh -l
	- chsh -s /path/to/zsh
	- sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

8. login to github and setup SSH

9. clone nvim-config to ~/.config/nvim
10. install paq for nvim
11. install node
12. finish nvim setup
13. setup wm conf from github as desired
    - install awesome with `paru -S awesome-git`
    - install themes with `git clone --recurse-submodules --remote-submodules --depth 1 -j 2 https://github.com/lcpz/awesome-copycats.git`
    - set theme filepaths properly with `mv -bv awesome-copycats/* ~/.config/awesome; rm -rf awesome-copycats`
    - install window decorations with `git clone https://github.com/mut-ex/awesome-wm-nice.git nice`
    - replace rc.lua with github version or modify as you like
    - if using gihub version copy github contents to themes/dremora/theme.lua
14. setup rofi
    - add following config to /etc/rofi.rasi
    ```
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
    ```

### Troubleshooting
### AWESOMEWM
#### Bad argument #1 to 'registerlock' (userdata expected, got nil)
gdk 3 & 4 do not play nice together change if you are using nice window decorations
find gdk require from nice files and change it:
```lua
--local gdk = lgi.require('Gdk')
local gdk = lgi.require('Gdk', '3.0')
```
