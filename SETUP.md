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

1. Generate a new SSH key

    ```sh
    ssh-keygen -f ~/.ssh/github -t ed25519 -C "<email>"
    ```

2. Start the ssh-agent in the background

    ```sh
    eval "$(ssh-agent -s)"
    ```

3. Add your SSH private key to the ssh-agent

    ```sh
    ssh-add --apple-use-keychain ~/.ssh/github
    ```

4. Copy the SSH public key to the clipboard

    ```sh
    pbcopy < ~/.ssh/github.pub
    ```

5. Add the SSH public key to your GitHub account

    ```sh
    open "https://github.com/settings/ssh"
    ```

6. Verify that the SSH key is added successfully

    ```sh
    ssh -T git@github.com
    ```

Clone the `dotfiles` repository under the `~/dotfiles` directory:

```sh
git clone git@github.com:dhruvmanila/dotfiles.git
```

Install the preferred packages mentioned in the [`Brewfile`](./src/package/Brewfile):

1. Install the bundler:

    ```sh
    brew tap homebrew/bundle
    ```

2. Install the packages:

    ```sh
    #  prints output from commands as they are run ┐
    #                                              │
    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle install -v --no-lock --file ~/dotfiles/src/package/Brewfile
    #                                                  │
    #         don't output a `Brewfile.lock.json` file ┘
    ```

3. Cleanup the Homebrew installation:

    ```sh
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

Setup the Python development environment using [`uv`](https://docs.astral.sh/uv/getting-started/installation/):
* Install Python versions using `uv python install ...`
* Install global Python packages using `uv tool install ...`

Install the global packages for multiple programming languages:
* For Python, use [`uv`](https://docs.astral.sh/uv/) with the [`requirements.txt`](./src/package/requirements.txt) file.
* For Node.js, use [`npm`](https://www.npmjs.com/) with the [`node_modules.txt`](./src/package/node_modules.txt) file.
* For Rust, use [`cargo`](https://doc.rust-lang.org/cargo/) with the [`cargo_packages.txt`](./src/package/cargo_packages.txt) file.

Build the latest stable Neovim version:

> [!NOTE]
>
> Make sure the [build prerequisites](https://github.com/neovim/neovim/blob/master/BUILD.md#build-prerequisites)
> are installed before building Neovim from source.

1. Clone the repository:

    ```sh
    mkdir ~/git && cd ~/git
    git clone git@github.com:neovim/neovim.git && cd ~/git/neovim
    ```

2. Checkout the `stable` branch (or `nightly`):

    ```sh
    git checkout stable
    ```

3. Build Neovim:

    ```sh
    make CMAKE_BUILD_TYPE="Release" CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=${HOME}/neovim" install
    ```

Build [`nnn`](https://github.com/jarun/nnn) terminal file manager with nerd-font icons:

1. Clone the repository:

    ```sh
    mkdir ~/git && cd ~/git
    git clone git@github.com:jarun/nnn.git && cd ~/git/nnn
    ```

2. Checkout the [latest stable version](https://github.com/jarun/nnn/releases/latest):

    ```sh
    git checkout <latest>
    ```

3. Install with nerd-font icons

    ```sh
    PREFIX=~/.local make O_NERD=1 install
    ```

Setup MacOS [`dock`](./bin/dock) applications and [update the preferences](./src/mac/osxdefaults).
