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

## Setup
Make sure that your Arch installation is up-to-date and Git is installed.
```console
sudo pacman -Syu
sudo pacman -Sy git
```


Run `init_system.sh` to get minimal dependencies with some sensible additions


Current setup:
- Chinese, Japanese, and Korean fonts in additions to basic latin letters
- Audio controls which are setup with AwesomeWM bindings
- Paru as the AUR helper
- kitty as the default terminal
- Rofi as the application switcher
- Diodon as the clipboard manager
- neovim-git version
- awesomewm-git version is used with slightly modified dremora theme
- brave-beta-bin is the default browser
- ZSH with some plugins, and powerlevel10k theme

After running setup script, create a new ssh key for github, and set it up for use.


Run the commands in `Importing dotfiles to system` section, but you can skip the submodules command since it's not used currently.


After installing everything reset configs to remote main with:
`dgit reset --hard origin/main`


## TODO
- git installation to init script
- script for github setup
- script for dotfiles init
- script for neovim setup
- wallpapers setup script

## Troubleshooting

### AWESOMEWM
Bad argument #1 to 'registerlock' (userdata expected, got nil)
gdk 3 & 4 do not play nice together change if you are using nice window decorations find gdk require from nice files and change it:

--local gdk = lgi.require('Gdk')
local gdk = lgi.require('Gdk', '3.0')
