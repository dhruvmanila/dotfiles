# dotfiles

Download the bootstrap script and run it in bash:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dhruvmanila/dotfiles/master/bootstrap)"
```

## What the script does?

**Download dotfiles:**

- Download the dotfiles tarball in `$HOME` directory
- Extract all the files and directories from the tarball in the `~/dotfiles` directory
- Remove the tarball

**Xcode command line tools:**

- Check whether the xcode command line tools are installed
- Install them if they are not installed and wait until it is installed

**Homebrew:**

- Check whether homebrew is installed
- Install homebrew if it is not installed
- Add the bundle tap and install all the softwares using Brewfile with the command: `brew bundle install -v --file ~/dotfiles/lib/packages/Brewfile`
- Switch to using brew installed bash by default (switch to zsh?)

**Git:**

- Install git using homebrew only if it was not installed with xcode command line tools
- Initialize and sync the local dotfiles repository with the remote

**Python installation:**

- `pyenv` and its pre-requisites are already installed from the `Brewfile`
- Install the latest Python and make it the global one
- Upgrade `pip` to the latest version
- Install `pipx` and all the global requirements from `lib/packages/requirements.txt`
- Upgrade the packages if they already exists

**Symlink dotfiles:**

- Create a backup of all the dotfiles if they exist in the directory `~/dotfiles_(date +"%Y_%m_%dT%H_%M_%S").backup`
- Create the symlink of all the necessary files and directories

**Vim and tmux plugins:**

* Update `vim-plug` plugin manager to the latest version
* Install all the plugins mentioned in the `vimrc` file or update them if they already exists
* Install `tpm` tmux plugin manager if it does not exist
* Install all the plugins mentioned in the `.tmux.conf` file or update them if they already exists

**Configure SSH for GitHub:**

* Check if the SSH keyfile named `github.pub` exists and test it using the command `ssh -T git@github.com`
* If the key does not exists, generate it and add it to the `ssh-agent`
* Copy the public key to clipboard and open the GitHub settings page
* Verify that the SSH key has been added using the above command for a maximum of 5 tries

**Update macos default settings:**

- Run the osxdefaults script
- Update dock apps using `dockutil`

### TODO:

- [ ]  Add function to restore all the files from `mackup`
- [ ]  Add multiple option to the bootstrap script like:
  * `update`: Update everything which includes homebrew, packages, softwares, languages, etc.
  * `link`: Force symlink creating the backup of existing dotfiles (no backup with the `-f/--force` flag?)
  * `macos`: Run the macos defaults script and update the dock content
  * `sync`: Keep all library files (`Brewfile`, `requirements.txt`, ...) synced with the currently installed packages
  * `backup`: Backup using `mackup` and `tmutil` (Time machine)
