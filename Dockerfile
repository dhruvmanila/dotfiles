FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

# Install any prerequisites for Ubuntu.
RUN apt-get update -y && \
  apt-get install -y \
    build-essential \
    locales \
    software-properties-common \
    xdg-utils \
    tzdata && \
  rm -rf /var/lib/apt/lists/*

# Update timezone inside the container.
# https://dev.to/0xbf/set-timezone-in-your-docker-image-d22
ENV TZ="Asia/Kolkata"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure tzdata

# Set image locale.
# https://hub.docker.com/_/ubuntu/ - Locales
RUN localedef \
    --force \
    --inputfile en_US \
    --charmap UTF-8 \
    --alias-file /usr/share/locale/locale.alias en_US.UTF-8

# Install development requirements.
# Neovim: https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable
# Python: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
# python#.#-venv: https://github.com/deadsnakes/issues/issues/79#issuecomment-463405207
RUN add-apt-repository ppa:neovim-ppa/unstable && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt-get update -y && \
  apt-get install -y \
    curl \
    git \
    htop \
    make \
    neovim \
    python3-pip \
    python3.9 \
    python3.9-venv \
    sudo \
    tmux \
    unzip \
    zsh && \
  rm -rf /var/lib/apt/lists/*

# Change the default shell to zsh
RUN chsh --shell '/bin/zsh'

# In Ubuntu, every Python executable is explicit in the version, so the
# default Python version in 20.04 is 3.8 which means there will be `python3`
# and `python3.8`. We want the default version to be 3.9.
RUN ln -sf /usr/bin/python3.9 /usr/local/bin/python && \
  ln -sf /usr/bin/python3.9 /usr/local/bin/python3

# Install latest NodeJS and npm.
# https://github.com/nodesource/distributions#installation-instructions
RUN bash -c "$(curl -fsSL https://deb.nodesource.com/setup_current.x)" && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

# Install `npm` global packages.
RUN npm install --global npm@latest && \
  npm install --global \
    bash-language-server \
    prettier \
    pyright \
    vscode-langservers-extracted \
    yaml-language-server \
    dockerfile-language-server-nodejs

# Install Starship prompt
# https://github.com/starship/starship#step-1-install-starship
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force

# Install GitHub CLI (`gh`)
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  apt-get update && \
  apt-get install gh && \
  rm -rf /var/lib/apt/lists/*

# Tool versions as build arguments.
ARG BAT_VERSION="0.20.0"
ARG BOTTOM_VERSION="0.6.8"
ARG FD_VERSION="8.3.2"
ARG RG_VERSION="13.0.0"

# Install tools from debian package to get the latest available version.
RUN curl -LO https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb && \
  curl -LO https://github.com/ClementTsang/bottom/releases/download/${BOTTOM_VERSION}/bottom_${BOTTOM_VERSION}_amd64.deb && \
  curl -LO https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd_${FD_VERSION}_amd64.deb && \
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep_${RG_VERSION}_amd64.deb && \
  dpkg --install bat_${BAT_VERSION}_amd64.deb && \
  dpkg -i bottom_${BOTTOM_VERSION}_amd64.deb && \
  dpkg --install fd_${FD_VERSION}_amd64.deb && \
  dpkg --install ripgrep_${RG_VERSION}_amd64.deb && \
  rm *.deb

# User information.
ENV USER="dhruv"
ENV UID="1000"
ENV GID="1000"

# Create the user group and add the user with zsh as the default shell.
RUN groupadd --gid $GID $USER && \
  useradd \
    --create-home \
    --shell /bin/zsh \
    --uid $UID \
    --gid $GID \
    $USER

ENV HOME="/home/$USER"
ENV DOTFILES="$HOME/dotfiles"

# Swap to the user so packages are not installed and run as root.
USER $USER
WORKDIR $HOME

# Install `fzf`
WORKDIR $HOME/git/fzf
RUN git clone https://github.com/junegunn/fzf . && \
  ./install --all --no-bash --no-fish

# Install `pipx` and global Python packages.
RUN python -m pip install --upgrade pip && \
  python -m pip install pipx && \
  python -m pipx install black && \
  python -m pipx install flake8 && \
  python -m pipx install isort && \
  python -m pipx install --include-deps jupyter && \
  python -m pipx inject --include-apps jupyter jupyterlab && \
  python -m pipx install mypy && \
  python -m pipx install pre-commit

# Setting up Neovim Python environment.
WORKDIR $HOME/.neovim
RUN python3 -m venv .venv && \
  . .venv/bin/activate && \
  pip3 install \
    debugpy \
    pynvim && \
  deactivate

# Copy all the files into the dotfiles directory requesting the ownership
# of the directory for the USER.
COPY --chown=$UID:$GID . $DOTFILES

# Create symlinks from the dotfiles directory to the respective path where
# the config files needs to be present.
RUN mkdir -p "$HOME/.config" && \
  mkdir -p "$HOME/.config/gh" && \
  ln -snf "$DOTFILES/.editorconfig" "$HOME/.editorconfig" && \
  ln -snf "$DOTFILES/config/bat" "$HOME/.config/bat" && \
  ln -snf "$DOTFILES/config/bottom" "$HOME/.config/bottom" && \
  ln -snf "$DOTFILES/config/gh/config.yml" "$HOME/.config/gh/config.yml" && \
  ln -snf "$DOTFILES/config/htop" "$HOME/.config/htop" && \
  ln -snf "$DOTFILES/config/nvim" "$HOME/.config/nvim" && \
  ln -snf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml" && \
  ln -snf "$DOTFILES/config/tmux/tmux.conf" "$HOME/.tmux.conf" && \
  ln -snf "$DOTFILES/config/zsh/zshenv" "$HOME/.zshenv" && \
  ln -snf "$DOTFILES/config/zsh/zshrc" "$HOME/.zshrc"

# Install Packer (Neovim plugin manager), plugins and treesitter parsers.
ENV NVIM_BOOTSTRAP=1
RUN nvim --headless -c "autocmd User PackerComplete :qall"

WORKDIR $HOME/work
ENTRYPOINT [ "zsh" ]
