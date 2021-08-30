# `dot`

## Install

_Run the command from the root directory_

```sh
make
```

## Usage

_Every mentioned flag has its short counterpart, e.g., `--force` or `-f`_

```sh
# run only when setting up a fresh machine
$ dot setup

# create the necessary/missing symlinks
$ dot link

# same as above, without creating a backup
$ dot link --force

# update macos dock applications
$ dot mac --dock

# update macos settings
$ dot mac --settings

# or update both
$ dot mac --dock --settings

# sync all the lib files with installed packages
$ dot sync

# or sync specific file(s) only
$ dot sync --brew
$ dot sync --node
$ dot sync --python

# upgrade everything
$ dot upgrade

# or upgrade specifc package, for package managers upgrade its installed packages
$ dot upgrade neovim
$ dot upgrade brew

# for packages which are manually installed like neovim, you can checkout to a
# specific ref (commit/tag/branch)
$ dot upgrade neovim --ref v0.5.0
```
