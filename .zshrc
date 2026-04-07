# This is required for correct glyphs rendering
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
PATH=$HOME/bin:$HOME/.local/bin:$PATH

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
FPATH="$HOME/.docker/completions:$FPATH"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Source Oh my posh
eval "$(oh-my-posh init zsh --config $HOME/.config/omp/omp.toml)"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab


# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region


# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Aliases
alias ls='ls --color'
alias c='clear'
alias rsh="source ~/.zshrc"

export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin" 

zcodei() {
  _result="$(zoxide query --interactive -- "$@")" && code "$_result"
}

flush_dns(){
 sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
}

verify_sha256() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: verify_sha256 <expected_hash> <file>"
        return 1
    fi
    
    local expected_hash="$1"
    local file="$2"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found"
        return 1
    fi
    
    local actual_hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    
    echo "Expected: $expected_hash"
    echo "Actual:   $actual_hash"
    
    if [[ "$expected_hash" == "$actual_hash" ]]; then
        echo "✅ Hash verification PASSED"
        return 0
    else
        echo "❌ Hash verification FAILED"
        return 1
    fi
}

remove_ssh_key_for_ip() {
   local ip="$1"
    
    if [ -z "$ip" ]; then
        echo "Usage: remove_ssh_ip <ip_address>"
        return 1
    fi
    
    # Validate IP format (basic check)
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "Error: Invalid IP address format"
        return 1
    fi
    
    echo "Removing SSH host key entries for IP: $ip"
    
    # Remove standard port 22 entry
    echo "Removing standard port 22 entry..."
    ssh-keygen -R "$ip"
    ssh-keygen -R "[$ip]:2222"

}
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
