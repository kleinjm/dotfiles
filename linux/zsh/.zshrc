export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# Needed for KDE wallet to work as the aws-vault store on Linux
export AWS_VAULT_BACKEND=kwallet

source "$DOTFILES_DIR"/shared/.zshrc
