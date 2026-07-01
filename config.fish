if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by Antigravity
# fish_add_path /Users/zachvp/.antigravity/antigravity/bin

# ensure pyenv shims precede homebrew in PATH
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/shims

# pyenv
pyenv init - | source

# ssh+agent
eval (ssh-agent -c > /dev/null)
ssh-add ~/.ssh/id_rsa >/dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 --apple-load-keychain >/dev/null 2>&1

# browsers
set -gx CHROMIUM_BINARY "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# common directories
set -gx ZPATH_TRACKS /Users/zachvp/developer/test-private/data/tracks
set -gx ZPATH_RE_ENCODED /Users/zachvp/developer/test-private/data/re-encoded
set -gx ZPATH_TO_RE_ENCODE /Users/zachvp/developer/test-private/data/to-re-encode
set -gx ZPATH_SCRIPTS_WRITE /Users/zachvp/developer/scripts/data/write
set -gx ZPATH_REKORDBOX_XML /Users/zachvp/Library/CloudStorage/OneDrive-Personal/Backups/rekordbox/collections

# x11 display
export DISPLAY=:0

# paths
fish_add_path /Users/zachvp/developer/flutter/bin
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.3.0/bin
fish_add_path /opt/homebrew/opt/grep/libexec/gnubin

# nvm
set -gx NVM_DIR "$HOME/.nvm"
alias nvm="bass source /opt/homebrew/opt/nvm/nvm.sh --no-use ';' nvm"

# golang versions
fish_add_path /Users/zachvp/go/bin/
fish_add_path /Users/zachvp/.dotnet/tools/

# rust
source "$HOME/.cargo/env.fish"

set -gx PATH $HOME/.npm-global/bin $PATH

# fd limit (due to running music-assistant server tests)
ulimit -n 4096

# opencode
fish_add_path /Users/zachvp/.opencode/bin

# Claude Pro billing cycle anchor (Friday 11am EDT = 15:00 UTC); used by cache-stats.sh --window since_epoch
set -gx CACHE_STATS_EPOCH "2026-06-26T15:00:00Z"

# always end on a high note
true
