function clip-paste --description 'Print the clipboard (macOS, Wayland, or X11)'
    if command -q pbpaste
        pbpaste
    else if set -q WAYLAND_DISPLAY; and command -q wl-paste
        wl-paste --no-newline
    else if set -q DISPLAY; and command -q xclip
        xclip -selection clipboard -o
    else
        # OSC 52 reads are widely disabled by terminals, so a headless session
        # has no clipboard to read; paste into the terminal instead.
        echo "clip-paste: no clipboard available in this session" >&2
        return 1
    end
end
