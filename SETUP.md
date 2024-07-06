# Setup

This is a living document that describes how to set up my personal development
environment. This is tailored to my personal preferences and needs.

Install Xcode Command Line Tools:

```sh
xcode-select --install
```

Install Homebrew as mentioned on the [official website](https://brew.sh/):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Setup SSH keys for GitHub:

```sh
# Generate a new SSH key
ssh-keygen -f ~/.ssh/github -t ed25519 -C "<email>"

# Start the ssh-agent in the background
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add --apple-use-keychain ~/.ssh/github

# Copy the SSH public key to the clipboard
pbcopy < ~/.ssh/github.pub

# Add the SSH public key to your GitHub account
open "https://github.com/settings/ssh"

# Verify that the SSH key is added successfully
ssh -T git@github.com
```

Clone the `dotfiles` repository under the `~/dotfiles` directory:

```sh
git clone git@github.com:dhruvmanila/dotfiles.git
```

Install the preferred packages mentioned in the [`Brewfile`](./src/package/Brewfile):

```sh
brew tap homebrew/bundle

#  prints output from commands as they are run ┐
#                                              │
HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install -v --no-lock --file ~/dotfiles/src/package/Brewfile
#                                                  │
#         don't output a `Brewfile.lock.json` file ┘

brew cleanup
```

> [!NOTE]
>
> Usually, you wouldn't want to install all the packages mentioned in the `Brewfile`.
> Prefer to install only the packages that you need.

Symlink the custom scripts to the `~/.local/bin` directory:

```sh
ln -vsf ~/dotfiles/bin/* ~/.local/bin
```

Create the symlinks between the files in the `dotfiles` repository and the home directory:

```sh
# It'll prompt you before creating each symlink
~/dotfiles/bin/link
```

> [!NOTE]
>
> You can force it to create the symlinks without prompting by passing the `--force` flag
> but that's not recommended.

Setup the Python development environment using the [`pyenv`](./bin/pyenv) script. Refer to `pyenv --help` for more information.

Install the global packages for multiple programming languages:
* For Python, use [`pipx`](https://pipxproject.github.io/pipx/) with the [`requirements.txt`](./src/package/requirements.txt) file.
* For Node.js, use [`npm`](https://www.npmjs.com/) with the [`node_modules.txt`](./src/package/node_modules.txt) file.
* For Rust, use [`cargo`](https://doc.rust-lang.org/cargo/) with the [`cargo_packages.txt`](./src/package/cargo_packages.txt) file.

Build the latest stable Neovim version:

> [!NOTE]
>
> Make sure the [build prerequisites](https://github.com/neovim/neovim/blob/master/BUILD.md#build-prerequisites)
> are installed before building Neovim from source.

```sh
mkdir ~/git && cd ~/git
git clone git@github.com:neovim/neovim.git && cd ~/git/neovim

# Install the latest stable version
git checkout stable

# Build Neovim
make CMAKE_BUILD_TYPE="Release" CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${HOME}/neovim" install
```

Build [`nnn`](https://github.com/jarun/nnn) terminal file manager with nerd-font icons:

```sh
mkdir ~/git && cd ~/git
git clone git@github.com:jarun/nnn.git && cd ~/git/nnn

# Refer to https://github.com/jarun/nnn to get the latest stable version
git checkout <latest>

# Install with nerd-font icons
PREFIX=~/.local make O_NERD=1 install
```

Setup MacOS [`dock`](./bin/dock) applications and [update the preferences](./src/mac/osxdefaults).
