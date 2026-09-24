function fish_prompt --description 'Write out the prompt'
    set -l laststatus $status

    set -l git_info
    if set -l git_branch (command git symbolic-ref HEAD 2>/dev/null | string replace refs/heads/ '')
        set git_branch (set_color -o blue)"$git_branch"
        set -l git_status
        # left side of HEAD...@{upstream} counts local-only commits (ahead),
        # right side counts upstream-only ones (behind); no upstream → no arrows
        if set -l count (command git rev-list --count --left-right HEAD...@{upstream} 2>/dev/null)
            echo $count | read -l ahead behind
            if test "$ahead" -gt 0
                set git_status "$git_status"(set_color red)⬆
            end
            if test "$behind" -gt 0
                set git_status "$git_status"(set_color red)⬇
            end
        end
        # porcelain lists untracked files too, which diff-index leaves out
        set -l changes (command git status --porcelain 2>/dev/null | string sub -l 2 | sort -u)
        if set -q changes[1]
            for i in $changes
                switch $i
                    case "A*"
                        set git_status "$git_status"(set_color green)✚
                    case " D"
                        set git_status "$git_status"(set_color red)✖
                    case "*M*"
                        set git_status "$git_status"(set_color green)✱
                    case "*R*"
                        set git_status "$git_status"(set_color purple)➜
                    case "*U*"
                        set git_status "$git_status"(set_color brown)═
                    case "??"
                        set git_status "$git_status"(set_color red)≠
                end
            end
        else
            set git_status "$git_status"(set_color green):
        end
        set git_info "(git$git_status$git_branch"(set_color white)")"
    end

    # joined to one string: printf below takes exactly one arg per %s
    set -l pyenv_info
    if command -q pyenv
        set pyenv_info (pyenv version-name 2>/dev/null | string split ':' | string match -v system | string join ':')
    end

    # Disable PWD shortening by default.
    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0

    set_color -b black
    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s' (date +%H:%M) ' ' (set_color -o white) '❰'(set_color white) ':' (set_color purple) $pyenv_info (set_color white) '❙' (set_color yellow) (prompt_pwd) (set_color white) $git_info (set_color white) '❱' (set_color white)
    if test $laststatus -eq 0
        printf "%s✔%s≻%s " (set_color -o green) (set_color white) (set_color normal)
    else
        printf "%s✘%s≻%s " (set_color -o red) (set_color white) (set_color normal)
    end
end
