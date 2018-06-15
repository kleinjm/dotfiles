# Dotfiles

## Mac
### Installing Fonts
* Run the `bin/dependencies.sh` file
* Open the font file saved in `mac_config` and install it to the Mac Font Book
  * `open mac_config/Fura\ Mono\ Regular\ Nerd\ Font\ Complete.otf`
* In iTerm, set the font to that font for the current profile
* Restart vim and you should see devicons

### Syncing Mac Mail Rules
* To save local rule to the repo `mac_config/mail/upload_local_rules.sh`
* To apply repo rules to the local mac mail `mac_config/mail/apply_dotfile_rules.sh`

### Sequel Pro
- Dark query scheme found in `mac_config/sequel-pro-master`

### Additional environment configurations
* Chrome theme - Dark Theme v3
* See `~/Dropbox/EnvironmentConfigurations/README.txt`

### Userscripts
Stored in bookmarks on my googlde chrome account.

### NVM
I set the system ~/.nvmrc -> dotfiles/nvmrc and have that fetching `node` which is the latest node version. Any project without a .nvmrc will use the latest since it will traverse up the dirs to find my root one

### TMUX
Default config taken from [oh-my-tmux](https://github.com/gpakosz/.tmux)

### Alfred
- I use [this script](https://github.com/stuartcryan/custom-iterm-applescripts-for-alfred) to get Alfred <> iTerm2 integration

### VIM
- Followed [this guide](https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html) to set up ctags using git hooks

### Music
Music is synced to my personal server space using `/mac/scripts/upload_music`. This only uploads the file difference and deletes any deleted songs. My server plan comes with 100GB of space.

### SSH
To set up ssh and rsync without asking for a password. See [this guide](https://www.thegeekstuff.com/2011/07/rsync-over-ssh-without-password/)
```
ssh-copy-id -i ~/.ssh/id_rsa.pub jamesmkl@jamesmklein.com
```
- See `$LOCAL_CONFIG` (vim `leader + lcl`) for additional configurations
