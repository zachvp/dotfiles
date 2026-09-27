# macOS-only environment: Homebrew, app bundles, and paths that exist on the Mac.
# conf.d runs before config.fish, so Homebrew lands in PATH first and the
# prepends in config.fish (pyenv shims, ~/.local/bin) still take precedence.
test (uname) = Darwin; or return

# Homebrew (PATH, MANPATH, HOMEBREW_*)
/opt/homebrew/bin/brew shellenv fish | source

fish_add_path -g /opt/homebrew/opt/ruby/bin
fish_add_path -g /opt/homebrew/lib/ruby/gems/3.3.0/bin
fish_add_path -g /opt/homebrew/opt/grep/libexec/gnubin
fish_add_path -g ~/Library/Android/sdk/platform-tools
fish_add_path -g ~/developer/flutter/bin
# python.org installer framework build
fish_add_path -g /Library/Frameworks/Python.framework/Versions/3.13/bin

# browsers
set -gx CHROMIUM_BINARY "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# common directories
set -gx ZPATH_TRACKS ~/developer/test-private/data/tracks
set -gx ZPATH_RE_ENCODED ~/developer/test-private/data/re-encoded
set -gx ZPATH_TO_RE_ENCODE ~/developer/test-private/data/to-re-encode
set -gx ZPATH_SCRIPTS_WRITE ~/developer/scripts/data/write
set -gx ZPATH_REKORDBOX_XML ~/Library/CloudStorage/OneDrive-Personal/Backups/rekordbox/collections

# x11 display (XQuartz)
set -gx DISPLAY :0

if status is-interactive
    # ssh: keys load into macOS's launchd-managed agent (com.openssh.ssh-agent),
    # whose socket launchd exports as SSH_AUTH_SOCK to every login session. One
    # agent serves all shells, so a shell starts none of its own.
    ssh-add ~/.ssh/id_rsa >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519 --apple-load-keychain >/dev/null 2>&1
    ssh-add ~/.ssh/id_ed25519_solreason --apple-load-keychain >/dev/null 2>&1

    # fd limit (due to running music-assistant server tests)
    ulimit -n 4096
end
