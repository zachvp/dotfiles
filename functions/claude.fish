function __claude_ide_detect --description 'print py/rust/cpp based on cwd markers, or nothing if undetected'
    if test -f Cargo.toml
        echo rust
    else if test -f pyproject.toml -o -f setup.py -o -f requirements.txt -o -f Pipfile
        echo py
    else if test -f CMakeLists.txt -o -f Makefile -o -f configure.ac
        echo cpp
    else
        set -l rs_hit (find . -maxdepth 1 -iname '*.rs' -print -quit)
        set -l py_hit (find . -maxdepth 1 -iname '*.py' -print -quit)
        set -l cpp_hit (find . -maxdepth 1 \( -iname '*.c' -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.h' -o -iname '*.hpp' \) -print -quit)
        if test (count $rs_hit) -gt 0
            echo rust
        else if test (count $py_hit) -gt 0
            echo py
        else if test (count $cpp_hit) -gt 0
            echo cpp
        end
    end
end

function __claude_ide_help --description 'print only the claude-ide extension help section'
    echo "usage: claude ide MODE [claude-args...]"
    echo ""
    echo "Launch claude with only one language-server plugin enabled,"
    echo "instead of all of clangd-lsp/pyright-lsp/rust-analyzer-lsp at once."
    echo ""
    echo "  py, python  only pyright-lsp enabled"
    echo "  rust        only rust-analyzer-lsp enabled"
    echo "  cpp, c      only clangd-lsp enabled"
    echo "  auto        detect py/rust/cpp from cwd markers (Cargo.toml, pyproject.toml, ...)"
    echo ""
    echo "any [claude-args...] are forwarded to claude as-is."
    echo "note: native 'claude --bare' only supports ANTHROPIC_API_KEY/apiKeyHelper auth"
    echo "(no OAuth/keychain), so it won't authenticate under a Pro/Max subscription."
    echo ""
    echo "pass -v/--verbose alongside -h/--help to also print vanilla 'claude --help' below this."
end

function claude --description 'claude, with an "ide" subcommand for scoped-plugin sessions'
    if test "$argv[1]" = "ide"
        set -l mode $argv[2]
        set -l rest $argv[3..-1]
        switch $mode
            case '' -h --help
                __claude_ide_help
                if contains -- -v $rest; or contains -- --verbose $rest
                    echo ""
                    echo "--- vanilla claude --help ---"
                    echo ""
                    command claude --help
                end
                return 0
            case py python
                command claude --settings '{"enabledPlugins":{"pyright-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $rest
            case rust
                command claude --settings '{"enabledPlugins":{"rust-analyzer-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"pyright-lsp@claude-plugins-official":false}}' $rest
            case cpp c
                command claude --settings '{"enabledPlugins":{"clangd-lsp@claude-plugins-official":true,"pyright-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $rest
            case auto
                if contains -- -h $rest; or contains -- --help $rest
                    set -l detected (__claude_ide_detect)
                    if test -z "$detected"
                        echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", would use plain claude"
                    else
                        echo "claude ide auto: would detect '$detected' in "(pwd)
                    end
                    echo "(pass -v/--verbose alongside -h/--help to also print vanilla claude --help)"
                    if contains -- -v $rest; or contains -- --verbose $rest
                        echo ""
                        echo "--- vanilla claude --help ---"
                        echo ""
                        command claude --help
                    end
                    return 0
                end
                set -l detected (__claude_ide_detect)
                set -l quiet 0
                contains -- -v $rest; and set quiet 1
                contains -- --version $rest; and set quiet 1
                if test -z "$detected"
                    test $quiet -eq 0; and echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", using default claude" >&2
                    command claude $rest
                else
                    test $quiet -eq 0; and echo "claude ide auto: detected $detected" >&2
                    claude ide $detected $rest
                end
            case '*'
                echo "claude ide: unknown mode '$mode' (expected: py, rust, cpp, auto)" >&2
                return 1
        end
    else
        command claude $argv
    end
end
