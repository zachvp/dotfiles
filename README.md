# dotfiles

Shell and editor config shared across machines, laid out as
[GNU Stow](https://www.gnu.org/software/stow/) packages. Each top-level
directory mirrors `$HOME`, and `stow <package>` symlinks it into place.

| Package | Links |
|---|---|
| `fish` | `~/.config/fish` |
| `vim`  | `~/.vimrc`, `~/.vim` (Pathogen; plugins in `bundle/` as git submodules) |

## Setup on a new machine

```sh
# Debian / Ubuntu / Armbian
sudo apt install git fish vim stow

# macOS
brew install git fish vim stow

git clone --recurse-submodules git@github.com:zachvp/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow fish vim

# make fish the login shell
command -v fish | sudo tee -a /etc/shells
chsh -s "$(command -v fish)"
```

`stow` refuses to overwrite real files, so move any existing `~/.config/fish`,
`~/.vimrc`, or `~/.vim` aside first.

## How the fish config is organized

- `config.fish` holds settings every machine shares. Paths go through
  `fish_add_path -g`, which adds a directory only when it exists, so one list
  serves every machine.
- `conf.d/os-darwin.fish` holds macOS setup (Homebrew, app paths, keychain
  ssh keys) and returns early elsewhere. A Linux counterpart goes in
  `conf.d/os-linux.fish` with `test (uname) = Linux; or return`.
- `functions/` holds one autoloaded function per file; `funcsave <name>`
  writes new ones here, straight into the repo.
- `fish_variables` is per-machine universal state and stays out of git.
- `clip-copy` / `clip-paste` pick pbcopy, wl-copy, or xclip per machine; on a
  headless machine over SSH, `clip-copy` uses OSC 52 to reach the local
  terminal's clipboard.

## Adding a vim plugin

```sh
git submodule add <plugin-url> vim/.vim/bundle/<name>
```
