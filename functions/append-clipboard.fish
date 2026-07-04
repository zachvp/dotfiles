function append-clipboard
    if test -z "$argv"
        echo "Usage: append-clipboard <file>"
        return 1
    end
    pbpaste >> $argv[1]
    echo "Appended clipboard to $argv[1]"
end
