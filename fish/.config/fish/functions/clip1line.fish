function clip1line
    clip-paste | sed 's/▎//g' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//' | clip-copy
    echo "Clipboard cleaned to one line."
end
