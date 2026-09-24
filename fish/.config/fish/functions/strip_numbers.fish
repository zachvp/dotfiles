function strip_numbers
    perl -0777 -pe 's/\d+\.\n?//g; s/\n{3,}/\n\n/g'
end
