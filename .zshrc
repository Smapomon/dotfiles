fastfetch
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# SET MANPAGER
export MANPAGER="nvim +Man!"

export VISUAL="nvim"

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
SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

function add_ssh_keys {
	echo "Adding keys..."
	for possiblekey in ${HOME}/.ssh/id_*; do
		if grep -q PRIVATE "$possiblekey"; then
			ssh-add "$possiblekey"
		fi

    ssh-add "smapo_host_yubi_key"
    ssh-add "ssh_key"
	done

}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

#source ~/packages/fzf-git/fzf-git.sh

# ------------ ALIASES ------------ #

# BASIC SHELL STUFF
alias cdf="cd \$(fd --type d --hidden --follow | fzf --color --scheme=path) && files"
alias ls="exa --long --header --icons --color=always --group-directories-first"
alias files="clear;ls -lh"
alias s="kitty +kitten ssh"
alias icat="wezterm imgcat"
alias update_kitty="curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
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

# ARCH SPECIFIC ALIASES
alias paru_updates="paru -Qu"
alias discord_update_skip="cd ~/.config/discordptb; clear; ls -alh; nvim settings.json"

# NAVIGATION ALIASES
alias dev='cd ~/dev; clear; ls -lh'
alias work='cd ~/dev/work; clear; ls -lh'
alias omni="cd ~/dev/gitlab/omnitool; clear; ls -lh"
alias sptla="cd ~/dev/work/spotilla-be; clear; ls -lh"
alias get_perm="cd ~/dev/work/perms; clear; ls -lh"
alias vimconf="cd ~/.config/nvim; clear; files; nvim init.lua"
alias wmconf="cd ~/.config/awesome; clear; files; nvim rc.lua"

# NAVIGATE WINDOW CLIENTS
alias fuzzy_win='wmctrl -i -a $(wmctrl -l | fzf | cut -d\  -f1); exit'

# SPTLA FUNCTIONS
alias specmigrate="docker compose run be rake db:migrate RAILS_ENV=test"
alias dspec="docker compose run be rspec ./spec/$1"
alias dspec_all="docker compose run be rspec ./spec"
alias jarru="clear; docker compose run be brakeman -A -z -I"

# DOCKER FUNCTIONS
alias dcup="clear; rm tmp/pids/server.pid; docker compose up"
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
alias ytdl="yt-dlp -o '%(title)s.%(ext)s' "
alias lines_of_code="cloc ."


# ------------ ALIAS FUNCTIONS ------------ #

function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

function _fuzzy_branches() {
  is_in_git_repo || return

  echo "Fetching branches..."
  git fetch -a -p &
  PID=$!
  i=0
  sp="/-\|"
  echo -n ' '
  while [ -d /proc/$PID ]; do
    c=`expr ${i} % 4`
    case ${c} in
      0) echo "/\c" ;;
      1) echo "-\c" ;;
      2) echo "\\ \b\c" ;;
      3) echo "|\c" ;;
    esac
    i=`expr ${i} + 1`

    sleep 0.05
    echo "\b\c"
  done

  current_branch="$(git branch --show-current | tr -d '\n')"

  git for-each-ref --sort='authordate:iso8601' --format='%(refname:lstrip=2)' |
  sed 's=origin/==g' | grep -v HEAD | sort | uniq |
  fzf --tac --no-mouse --cycle --border=bottom --border-label="|| current: $current_branch ||" \
  --bind 'enter:execute(echo {} | xargs git checkout)+abort,tab:execute-silent(echo {} | pbcopy)+abort'
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

export PATH="$HOME/.local/kitty.app/bin:$PATH"

export PATH="$HOME/dev/android_studio/android-studio-2021.3.1.16-linux/android-studio/bin:$PATH"
export PATH="/usr/java/jre1.8.0_341/bin:$PATH"
alias luamake=/luamake
export PATH="${HOME}/lsp_servers/lua-language-server/bin:${PATH}"
export PATH=/usr/local/bin/aws_completer:$PATH

##### XDG DIR CHANGES #####
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

PATH="/home/smapo/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/smapo/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/smapo/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/smapo/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/smapo/perl5"; export PERL_MM_OPT;

autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

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

# Custom appends through shell
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
nvm use node
