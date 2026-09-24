function clip-whatsapp --description 'Convert clipboard Markdown to WhatsApp formatting'
    pbpaste | python3 ~/developer/scripts/md2whatsapp.py | pbcopy
    and echo "Clipboard converted to WhatsApp formatting."
end
