# Mac
## Setup
* Make sure you're on the latest Mac OS
* Run `mac/make.sh`
* This repo assumes the home dir is `jklein`. If it's not, symlink it with the following
  ```sh
  cd /Users
  sudo ln -s james jklein
  ```

### Installing Fonts
* Open the font file saved in `mac_config` and install it to the Mac Font Book
  * `open mac_config/Fura\ Mono\ Regular\ Nerd\ Font\ Complete.otf`
* In iTerm, set the font to that font for the current profile
* Restart vim and you should see devicons

### Syncing Mac Settings
* To save local settings to the repo `mac/scripts/backup_settings.sh`
* To apply repo settings to the local mac `mac/scripts/restore_settings.sh` (part of `make` script)

### Sequel Pro
- Dark query scheme found in `mac_config/sequel-pro-master`

### Additional environment configurations
* Chrome theme - Dark Theme v3
* See `$PRIVATE_CONFIGS_DIR/README.txt`

### Userscripts
Stored in bookmarks on my googlde chrome account.

### NVM
I set the system ~/.nvmrc -> dotfiles/nvmrc and have that fetching `node` which is the latest node version. Any project without a .nvmrc will use the latest since it will traverse up the dirs to find my root one

### TMUX
Default config taken from [oh-my-tmux](https://github.com/gpakosz/.tmux)

### Alfred
- Settings are stored in the private env config path in dropbox.
- This should already be stored in settings but if not, use [this script](https://github.com/stuartcryan/custom-iterm-applescripts-for-alfred) to get Alfred <> iTerm2 integration

### VIM
- Followed [this guide](https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html) to set up ctags using git hooks
- Use [vim-projections](https://github.com/tpope/vim-projectionist) to define alternate files as explained [here](https://noahfrederick.com/log/vim-templates-with-ultisnips-and-projectionist). Each project has a `.projections.json` defined and globally git ignored.
- Install pythonx dependencies with the following. Note that `vim-pyenv` takes care of using the pyenv, not system version of python.
```sh
pip install -r vim/pythonx/requirements.txt
```

### Music & iTunes
- Music is synced to my personal server space using `/mac/scripts/upload_music`. This only uploads the file difference and deletes any deleted songs. My server plan comes with 100GB of space.
- For Alfred iTunes miniplayer: In iTunes go to Preferences > Advanced > Share iTunes Library XML with other applications

### SSH
To set up ssh and rsync without asking for a password. See [this guide](https://www.thegeekstuff.com/2011/07/rsync-over-ssh-without-password/)
NOTE: the same `id_rsa.pub` is shared so this should not be necessary
```
ssh-copy-id -i ~/.ssh/id_rsa.pub jamesmkl@jamesmklein.com
```
- See `$LOCAL_CONFIG` (vim `leader + lcl`) for additional configurations

### Neovim
I'm not using neovim currently but to get it set up I used the following
```
brew install neovim
created ~/.config/nvm/init.vim

# run :checkhealth

# https://github.com/zchee/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
sudo pip2 install --user neovim
sudo pip3 install --user neovim

gem install neovim
```

### Brew
Run `brew bundle dump --force` to update the Brewfile

### Quiver
- Quiver settings are stored in the root dir with default file name `Quiver-settings.json`

### Troubleshooting
- If you're getting a message about `__init_nvm` not being defined, nvm likely added something to the .zshrc. Check the bottom of the file.

# Linux
## Setup
- Run `linux/scripts/dependencies.sh`

### Shortkeys
- `linux/shortkeys.json` contains the shortcuts for the Shortkeys chrome extension

### Apt-get
- Packages and sources are backed up as part of the dependency scripts

### Apple Magic Mouse
- The apt_get.sh dependency script installs a tool called Ukuu that can be used to manage the kernel version
- Type `uname -a` to find out your version. It needs to be >= 4.18.0. See https://github.com/rohitpid/Linux-Magic-Trackpad-2-Driver#installation-with-dkms
- Start Ukuu and select kernel 4.20.0 (tested with this one and it works)
- Restart
- Run `linux/scripts/setup_magic_mouse.sh`
