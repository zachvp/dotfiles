# Added by Antigravity
# fish_add_path /Users/zachvp/.antigravity/antigravity/bin

# ensure pyenv shims precede homebrew in PATH
set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/shims

# pyenv
pyenv init - | source

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
fish_add_path $HOME/.local/bin
fish_add_path /Users/zachvp/developer/flutter/bin
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.3.0/bin
fish_add_path /opt/homebrew/opt/grep/libexec/gnubin
fish_add_path ~/Library/Android/sdk/platform-tools

# golang versions
fish_add_path /Users/zachvp/go/bin/
fish_add_path /Users/zachvp/.dotnet/tools/

# rust
source "$HOME/.cargo/env.fish"

set -gx PATH $HOME/.npm-global/bin $PATH

# opencode
fish_add_path /Users/zachvp/.opencode/bin

# Claude Pro billing cycle anchor (Friday 11am EDT = 15:00 UTC); used by cache-stats.sh --window since_epoch
set -gx CACHE_STATS_EPOCH "2026-06-26T15:00:00Z"

# non-interactive session: bypass fish entirely (tool-driven Bash calls land here).
# Env/PATH above this line are inherited via exec; anything below is interactive-only.
# NOTE: this also swallows `fish -c '...'` from non-TTY callers — exec replaces the
# process before -c's command runs, so it silently no-ops instead of erroring.
# Use `fish --no-config -c '...'` to actually test fish functions/config non-interactively.
if not status is-interactive
    exec bash
end

# direnv (per-directory env vars, e.g. GH_CONFIG_DIR scoping)
direnv hook fish | source

# claude-kit: claude ide wrapper. Regenerated at each startup from claude-kit's
# init.lib.sh, the single source of truth across bash/zsh/fish — this supersedes
# the hand-maintained functions/claude.fish, which drifted from it for two months.
/Users/zachvp/developer/sol_reason/claude-kit/plugins/claude-kit/bin/claude-ide init fish | source

# ssh: keys load into macOS's launchd-managed agent (com.openssh.ssh-agent),
# whose socket launchd exports as SSH_AUTH_SOCK to every login session. One
# agent serves all shells, so a shell starts none of its own.
ssh-add ~/.ssh/id_rsa >/dev/null 2>&1
ssh-add ~/.ssh/id_ed25519 --apple-load-keychain >/dev/null 2>&1
ssh-add ~/.ssh/id_ed25519_solreason --apple-load-keychain >/dev/null 2>&1

# nvm
set -gx NVM_DIR "$HOME/.nvm"
alias nvm="bass source /opt/homebrew/opt/nvm/nvm.sh --no-use ';' nvm"

# fd limit (due to running music-assistant server tests)
ulimit -n 4096

# always end on a high note
true


# Added by Antigravity CLI installer
set -gx PATH "/Users/zachvp/.local/bin" $PATH

# cwd
cd /Users/zachvp/developer/sol_reason
