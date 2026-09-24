function latest
    set dir $argv[1]
    if test -z "$dir"
        set dir .
    end
    set dir (string replace -r '/$' '' $dir)
    ls -t $dir | head -n 1 | xargs -I {} echo $dir/{}
end
