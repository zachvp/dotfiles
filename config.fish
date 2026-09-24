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

# ~/.local/bin goes last so it lands first in PATH, ahead of Homebrew and the
# other prepends above; --move reorders it even when the launching env has it.
fish_add_path --move $HOME/.local/bin

# Everything above runs for every fish, so scripts and `fish -c` get the same
# env/PATH as a terminal. Claude Code's Bash tool runs bash directly
# (CLAUDE_CODE_SHELL in ~/.claude/settings.json), so it never lands here.
# The block below is for interactive shells: it prints, prompts, or costs a
# subprocess per startup.
if status is-interactive
    # direnv (per-directory env vars, e.g. GH_CONFIG_DIR scoping)
    direnv hook fish | source

    # claude-kit: claude-ide wrapper, generated at each startup from claude-kit's
    # init.lib.sh, the single source of truth across bash/zsh/fish.
    set -l claude_ide ~/developer/sol_reason/claude-kit/plugins/claude-kit/bin/claude-ide
    test -x $claude_ide; and $claude_ide init fish | source

    # ssh: keys load into macOS's launchd-managed agent (com.openssh.ssh-agent),
    # whose socket launchd exports as SSH_AUTH_SOCK to every login session. One
    # agent serves all shells, so a shell starts none of its own.
    ssh-add ~/.ssh/id_rsa >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 --apple-load-keychain >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519_solreason --apple-load-keychain >/dev/null 2>&1

    # fd limit (due to running music-assistant server tests)
    ulimit -n 4096
end
