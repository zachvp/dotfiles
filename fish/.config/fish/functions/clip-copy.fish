function clip-copy --description 'Copy stdin to the clipboard (macOS, Wayland, X11, or OSC 52 over SSH)'
    if command -q pbcopy
        pbcopy
    else if set -q WAYLAND_DISPLAY; and command -q wl-copy
        wl-copy
    else if set -q DISPLAY; and command -q xclip
        xclip -selection clipboard
    else
        # OSC 52 asks the terminal emulator itself to set its clipboard, so a
        # headless machine reached over SSH copies to the local desktop.
        printf '\e]52;c;%s\a' (base64 | tr -d '\n')
    end
end
