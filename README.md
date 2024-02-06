All my configuration files I wish to make portable.
Checkout setup.md for installation without copying from repo

## Current Setups
These will probably change in the future.
Especially main, as it will always be my daily driver OS.
New ones will be added each time I start using a new OS or a TWM.


### Branches
#### main
```
OS       = Archlinux
GRAPHICS = XORG
TWM      = awesomewm
```


## Installation
Installation processes
### Importing dotfiles to system
```console
git clone --separate-git-dir=~/.dotconf git@github.com:Smapomon/dotfiles.git $HOME/myconf-tmp
cp ~/myconf-tmp/.gitmodules ~  # If you use Git submodules
rm -r ~/myconf-tmp/
alias dgit='/usr/bin/git --git-dir=$HOME/.dotconf/ --work-tree=$HOME'
```

### Making a new dotfiles repo
Use git init to create a new directory with bare repo
.dotconf, .myconf or any other directory can be used
```console
git init --bare $HOME/.dotconf
```

Create an alias to bashr, zshrc or whichever shell system you use.
Alias will make it easier to access the repo since using git without options will not work.
Note that when installing to a new system from the repo, the alias is automatically going to be in the zshrc (in this case).
```
alias dgit='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
```

Turn off untracked files in status (there will be many)
```console
dgit config status.showUntrackedFiles no
```

Finally add your new empty repo in github/gitlab to the bare repo remote.
Instructions for this can be seen when creating a new empty repo in github for example.


## Software/Tools
### Pacman:
```
[
  1password, arandr, awesome, bat, bluez, bluez-utils, brave-beta-bin, diodon,
  discord-ptb, docker, docker-compose, ferdium-bin, git, gnome-keyring, i3lock,
  imagemagick, man-db, man-pages, neofetch, neovim, nitrogen, obs-studio, openvpn,
  paru, pavucontrol, picom-jonaburg-git, qbittorrent, rbenv, ripgrep, rofi, scrot, slack-desktop,
  solaar, spotify, the_silver_searcher, vlc, xclip, zsh
]
```

arandr:              GUI for handling some of the xrandr screen stuff

bat:                 cat but better

bluez:               bluetooth stuff

diodon:              clipboard manager (history)

ferdium-bin:         whatsapp

neofetch:            show pretty system info on shell startup

neovim:              text editor weapon of choice

nitrogen:            manage wallpapers

paru:                AUR helpers

pavucontrol:         control sound

picom-jonaburg-git:  compositor for transparency, and blur

ripgrep:             very fast search

rofi:                search and open task switcher

scrot:               screenshot snipping

solaar:              for monitoring logitech devices

the_silver_searcher: more search stuff

## Setup
### Things to install:
To get a minimal working setup (with sensible additions), install the following:
```
paru (https://github.com/Morganamilo/paru)
alsa-utils
nice (https://github.com/mut-ex/awesome-wm-nice)
awesomewm-copycat (https://github.com/lcpz/awesome-copycats)
picom
kitty
zsh
oh-my-zsh
powerlevel10k
awesome-git (paru)
nvm
neovim
paq (https://github.com/savq/paq-nvim)
zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)
zsh-syntax-highlight (https://github.com/zsh-users/zsh-syntax-highlighting)
playerctl (for media keys)
ripgrep
the_silver_searcher
pavucontrol
rofi
diodon (paru)
ttf-iosevka (paru)

# for laptop or other devices with displaylink hubs
linux-headers
evdi-git (paru)
displaylink (paru & remember to check archwiki for enabling and config)

# for docker development
docker (remember to enable+start docker.service)
docker-compose

```

After installing everything reset configs to remote main with:
`dgit reset --hard origin/main`


## TODO
- add shell script for installing dependencies
