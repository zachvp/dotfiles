function clip-whatsapp --description 'Convert clipboard Markdown to WhatsApp formatting'
    clip-paste | python3 ~/developer/scripts/md2whatsapp.py | clip-copy
    and echo "Clipboard converted to WhatsApp formatting."
end
