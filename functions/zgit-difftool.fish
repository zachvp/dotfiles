function zgit-difftool --description 'git difftool with IntelliJ/JVM log noise filtered out'
    git difftool $argv 2>&1 | grep -Ev '^\s*(2[0-9]{3}-[0-9]{2}-[0-9]{2} .*\[.*\]\s+(WARN|INFO)|Plugin .* (has dependency on|requires plugin)|WARNING: .*(sun\.misc\.Unsafe|deprecated method|Please consider reporting))'
end
