# dotfiles

Shell and editor config shared across machines, laid out as
[GNU Stow](https://www.gnu.org/software/stow/) packages. Each top-level
directory mirrors `$HOME`, and `stow <package>` symlinks it into place.

| Package | Links                                                                   |
|---------|-------------------------------------------------------------------------|
| `fish`  | `~/.config/fish`                                                        |
| `vim`   | `~/.vimrc`, `~/.vim` (Pathogen; plugins in `bundle/` as git submodules) |

## Setup on a new machine

`stow` refuses to overwrite real files, so move any existing `~/.config/fish`,
`~/.vimrc`, or `~/.vim` aside first.

```sh
# Debian / Ubuntu / Armbian
sudo apt install git fish vim stow

# macOS
brew install git fish vim stow

git clone --recurse-submodules git@github.com:zachvp/dotfiles.git ~/dotfiles
cd ~/dotfiles
mkdir -p ~/.config
stow fish vim

# make fish the login shell
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"
```

## How the fish config is organized

- `config.fish` holds settings every machine shares. Paths go through
  `fish_add_path -g`, which adds a directory only when it exists.

- `conf.d/os-darwin.fish` holds macOS setup (Homebrew, app paths, keychain
  ssh keys), and returns early on non-Mac platforms. Other OS counterparts, e.g., Linux, go in
  `conf.d/os-linux.fish`, using the `test (uname) = Linux; or return` OS guard at the top.

- `functions/` holds one autoloaded function per file.

- The `fish_variables` file is per-machine universal state and is gitignored.

## How to add a `vim` plugin

```sh
git submodule add <plugin-url> vim/.vim/bundle/<name>
```
