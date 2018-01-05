## Dotfiles

### Installing Fonts
* Run the `bin/dependencies.sh` file
* Open the font file saved in `mac_config` and install it to the Mac Font Book
* In iTerm, set the font to that font for the current profile
* Restart vim and you should see devicons

### Syncing Mac Mail Rules
* To save local rule to the repo `mac_config/mail/upload_local_rules.sh`
* To apply repo rules to the local mac mail `mac_config/mail/apply_dotfile_rules.sh`

### Additional environment configurations
* Chrome theme - Dark Theme v3

### Userscripts
Mostly stored in bookmarks on my googlde chrome account.

- [Rubydoc dark](https://userstyles.org/styles/145687/dark-rubydoc-info)

### NVM
I set the system ~/.nvmrc -> dotfiles/nvmrc and have that fetching `node` which is the latest node version. Any project without a .nvmrc will use the latest since it will traverse up the dirs to find my root one
