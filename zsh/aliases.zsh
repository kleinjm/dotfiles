# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.
# Don't forget that zsh plugins like git include their own aliases

# shell commands
alias ls="ls -FGhla" # -F symbols, -G colorized output, -h full unit (Kilobyte)

# Brew
# Remove pyenv configs as not to interfere with brew
alias brew="env PATH=${PATH//$(pyenv root)\/shims:/} brew"
