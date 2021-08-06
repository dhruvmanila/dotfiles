# Bash configuration

## Fzf

If `fzf` is installed using `brew`, install the fuzzy completion and keybindings using:

```bash
/usr/local/opt/fzf/install --all --no-zsh
```

This will install a file `~/.fzf.bash` which is being sourced in `bashrc`. Do _NOT_ edit the line which sources the file as the installer can recognize the presence of the line and avoid duplication.
