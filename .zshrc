fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SET MANPAGER
export MANPAGER="nvim +Man!"

# SET DEFAULT EDITOR
export EDITOR="nvim"
export VISUAL="nvim"
export SYSTEMD_EDITOR="nvim"

# XDG Variables
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

# setup language variables
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
source $ZSH/oh-my-zsh.sh

# ------------ NVM SETUP ------------ #
source /usr/share/nvm/init-nvm.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ------------ SSH SETUP ------------ #
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)" > /dev/null 2>&1
  ssh-add -q "$HOME/.ssh/id_personal_github"
  ssh-add -q "$HOME/.ssh/id_work_gitlab"
fi

#source ~/packages/fzf-git/fzf-git.sh

# ------------ ALIASES ------------ #

# BASIC SHELL STUFF
alias cdf="cd \$(fd --type d --hidden --follow | fzf --color --scheme=path) && files"
alias ls="exa --long --header --icons --color=always --group-directories-first"
alias files="clear;ls -lh"
alias icat="wezterm imgcat"
alias termconf="cd ~; clear; nvim .zshrc"
alias :q="exit"
alias :qa="exit"
alias sdn="shutdown now"
alias restart_audio="systemctl --user restart pipewire.service"
alias set_caps_escape="~/shell_scripts/set_caps_escape.sh"
alias set_mouse="~/shell_scripts/set_mouse.sh"
#alias print_disks="lsblk -e7,254 -A -o NAME,FSTYPE,LABEL,MOUNTPOINT,FSUSE%,FSSIZE | grep -v 'nvme1n1.*\|nvme0n1p3.*\|nvme0n1p4.*'"
alias print_disks="lsblk -e 254 -A -o NAME,FSTYPE,LABEL,MOUNTPOINT,FSUSE%,FSSIZE"
alias ip='ip -c'
alias chown_all='sudo chown -R $USER:$USER *'

# GIT ALIASES
alias c_branch="git branch --show-current | tr -d '\n' | xclip -selection clipboard"
alias dgit='/usr/bin/git --git-dir=$HOME/.dotconf/ --work-tree=$HOME'
alias git_prune="git fetch -p && git branch -vv | grep 'origin/.*: gone]' | grep -v '\*' | awk '{print \$1}' | xargs git branch -d"
alias git_hard_prune="git fetch -p && git branch -vv | grep 'origin/.*: gone]' | grep -v '\*' | awk '{print \$1}' | xargs git branch -D"
alias gco="_fuzzy_branches"
alias gdel="_find_delete_branch"
gitlog() {
  local count="${1:-10}" # default to 10
  git log --max-count="$count" | nvim -R -
}

# ARCH SPECIFIC ALIASES
alias paru_updates="paru -Qu"
alias paru_fzf="paru -Sy \$(paru -Qu | fzf | cut -d \" \" -f 1)"
alias discord_update_skip="cd ~/.config/discordptb; clear; ls -alh; nvim settings.json"

# NAVIGATION ALIASES
grepcd() {
  local dir
  dir="$($HOME/shell_scripts/grepcd.sh "$@")" || return
  if [ -d "$dir" ]; then
    cd "$dir"; clear; ls -lh
  else
    echo "$dir"
  fi
}
alias dev='grepcd -d'
alias notes='cd ~/dev/notes/brain/; clear; ls -lh'
alias work='cd ~/dev/work; clear; ls -lh'
alias omni="cd ~/dev/gitlab/omnitool; clear; ls -lh"
alias sptla="cd ~/dev/work/spotilla-be; clear; ls -lh"
alias get_perm="cd ~/dev/work/perms; clear; ls -lh"
alias vimconf="cd ~/.config/nvim; clear; files; nvim init.lua"
alias wmconf="cd ~/.config/hypr; clear; files; nvim hyprland.conf"
alias pit="cd ~/dev/github/networthly; clear; files;"
alias nw="cd ~/dev/github/networthly; clear; files;"

# SPTLA FUNCTIONS
alias specmigrate="docker compose run be rake db:migrate RAILS_ENV=test"
alias dspec="docker compose run be rspec ./spec/$1"
alias dspec_all="docker compose run be rspec ./spec"
alias jarru="clear; docker compose run be brakeman -A -z -I"

# DOCKER FUNCTIONS
alias dcup="clear; rm tmp/pids/server.pid; docker compose up --remove-orphans"
alias dc_debug="clear; rm tmp/pids/server.pid; docker compose run --service-ports be"
alias dbld="clear; docker compose build"
alias docker_start="sudo systemctl start docker.service"

# RAILS FUNCTIONS
alias rcon="open_console"
alias genmodel_no_migrate="genmodel_without_migration_function $1"
alias genmodel="genmodel_with_migration_function $1"
alias genmigration="genmigrationonly_function $1"
alias genjob="generate_bg_job $1"
alias droutes="rails_routes"
alias dcmigraationes="run_migrations"
alias dcmigrationstatus="run_migration_status"
alias dcrollback="rollback_migration"
alias dbundle="run_bundle"
alias dbundle_install="install_with_bundle"


# File operations
alias lines_of_code="cloc ."

# most of the time it's better to just use the yt-dlp directly since
# it needs to be run from python venv
# `python -m venv ytenv`
# `ytenv/bin/pip install yt-dlp`
# `ytenv/bin/yt-dlp -o '%(title)s.%(ext)s' URL`
alias ytdl="yt-dlp -o '%(title)s.%(ext)s' "


# ------------ ALIAS FUNCTIONS ------------ #

function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

function _find_delete_branch() {
  is_in_git_repo || return

  fetch_branches_with_spinner
  current_branch="$(git branch --show-current | tr -d '\n')"

  selected_branch=$(list_sorted_branches |
    fzf --tac --no-mouse --cycle \
    --border=bottom \
    --border-label="|| current: $current_branch ||")

  if [ -n "$selected_branch" ]; then
    # Confirm branch exists locally before deleting
    if git show-ref --verify --quiet "refs/heads/$selected_branch"; then
      git branch -D "$selected_branch"
    else
      echo "❌ '$selected_branch' not found locally."
    fi

    git push origin --delete "$selected_branch"
  fi
}

function _fuzzy_branches() {
  is_in_git_repo || return

  fetch_branches_with_spinner
  current_branch="$(git branch --show-current | tr -d '\n')"

  list_sorted_branches |
  fzf --tac --no-mouse --cycle --border=bottom --border-label="|| current: $current_branch ||" \
  --bind 'enter:execute(echo {} | xargs git checkout)+abort,tab:execute-silent(echo {} | pbcopy)+abort'
}

function fetch_branches_with_spinner() {
  echo "Fetching branches..."
  git fetch -a -p &
  PID=$!
  i=0
  sp="/-\|"
  echo -n ' '
  while kill -0 "$PID" 2>/dev/null; do
    len=${#sp}
    c=$((i % len))
    printf "\b${sp:$c:1}"
    ((i++))
    sleep 0.05
  done
}

function list_sorted_branches() {
  git for-each-ref --sort='authordate:iso8601' --format='%(refname:lstrip=2)' |
  sed 's=origin/==g' | grep -v HEAD | sort | uniq
}

function rails_dir_map {
	CDIR=${PWD##*/}
	APPNAME=''
	case $CDIR in
		spotilla-be)
			APPNAME="be"
			;;
    api)
			APPNAME="api"
      ;;
		*)
			APPNAME="omnitool"
			;;
	esac

	echo $APPNAME;
}

function rails_env_append() {
	env_append=""

	if [[$1 == 'be']]; then
		env_append=" RAILS_ENV=development"
	fi

	return $env_append;
}

function open_console() {
	docker_instance_name=$(rails_dir_map)
	ex_command="clear; docker compose run $docker_instance_name rails c"
	eval $ex_command;
}

function genmodel_without_migration_function() {
	modelname=$1
	docker_instance_name=$(rails_dir_map)
	ex_command="docker compose run $docker_instance_name rails g model $modelname --skip-migration --no-test-framework"
	eval $ex_command;
}

function genmodel_with_migration_function() {
	modelname=$1
	docker_instance_name=$(rails_dir_map)
	ex_command="docker compose run $docker_instance_name rails g model $modelname --no-test-framework"
	eval $ex_command;
}

function genmigrationonly_function() {
	migrationname=$1
	docker_instance_name=$(rails_dir_map)
	ex_command="docker compose run $docker_instance_name rails g migration $migrationname"
	eval $ex_command;
}

function generate_bg_job() {
  jobname=$1
  docker_instance_name=$(rails_dir_map)
  ex_command="docker compose run $docker_instance_name rails g job $jobname --no-test-framework"
  eval $ex_command
}

function rails_routes() {
	docker_instance_name=$(rails_dir_map)
	ex_command="docker compose run $docker_instance_name rake routes"
	eval $ex_command;
}

function run_migrations() {
	docker_instance_name=$(rails_dir_map)
	echo "docker name: $docker_instance_name"
	env_append_str=rails_env_append $docker_instance_name
	ex_command="docker compose run $docker_instance_name rake db:migrate$env_append_str"
	echo $ex_command
	eval $ex_command;
}

function run_migration_status() {
	docker_instance_name=$(rails_dir_map)
	env_append_str=rails_env_append $docker_instance_name
	ex_command="docker compose run $docker_instance_name rake db:migrate:status$env_append_str"
	eval $ex_command;
}

function rollback_migration() {
	docker_instance_name=$(rails_dir_map)
	env_append_str=rails_env_append $docker_instance_name
	ex_command="docker compose run $docker_instance_name rake db:rollback$env_append_str"
	eval $ex_command;
}

function run_bundle() {
	docker_instance_name=$(rails_dir_map)
	ex_command="clear;docker compose run $docker_instance_name bundle"
	eval $ex_command;
}

function install_with_bundle() {
	docker_instance_name=$(rails_dir_map)
	ex_command="clear;docker compose run $docker_instance_name bundle install"
	eval $ex_command;
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH="$HOME/dev/android_studio/android-studio-2021.3.1.16-linux/android-studio/bin:$PATH"
export PATH="/usr/java/jre1.8.0_341/bin:$PATH"
alias luamake=/luamake
export PATH="${HOME}/lsp_servers/lua-language-server/bin:${PATH}"
export PATH=/usr/bin/aws_completer:$PATH

export ANDROID_SDK_ROOT="/home/smapo/Android/Sdk"
export ANDROID_HOME="/home/smapo/Android/Sdk"

##### XDG DIR CHANGES #####
export AWS_PROFILE="frostbit"
export AWS_DEFAULT_PROFILE="frostbit"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export NVM_DIR="$XDG_DATA_HOME"/nvm
export PSQL_HISTORY="$XDG_DATA_HOME/psql_history"
export RBENV_ROOT="$XDG_DATA_HOME"/rbenv
export SOLARGRAPH_CACHE="$XDG_CACHE_HOME"/solargraph
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
##### XDG DIR CHANGES #####

PATH="/home/smapo//perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/smapo/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/smapo/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/smapo/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/smapo/perl5"; export PERL_MM_OPT;

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/bin/aws_completer' aws

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

export PATH="$HOME/packages/flutter/bin:$PATH"
export PATH="$PATH":"$HOME/.pub-cache/bin"


###-begin-flutter-completion-###
if type complete &>/dev/null; then
  __flutter_completion() {
    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           flutter completion -- "${COMP_WORDS[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -F __flutter_completion flutter
elif type compdef &>/dev/null; then
  __flutter_completion() {
    si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 flutter completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef __flutter_completion flutter
elif type compctl &>/dev/null; then
  __flutter_completion() {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       flutter completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K __flutter_completion flutter
fi

###-end-flutter-completion-###

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/etc/profile.d/conda.sh" ]; then
        . "/usr/etc/profile.d/conda.sh"
    else
        export PATH="/usr/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
nvm use node > /dev/null 2>&1

# pnpm
export PNPM_HOME="/home/smapo/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

WEBKIT_DISABLE_DMABUF_RENDERER=1
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

export PATH=$PATH:$(go env GOPATH)/bin

echo "Ready!"
