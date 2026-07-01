function clip1line
    pbpaste | sed 's/▎//g' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//' | pbcopy
    echo "Clipboard cleaned to one line."
end
