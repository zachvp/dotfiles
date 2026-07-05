function __claude_ide_plugin_json --description 'build enabledPlugins JSON, OR-ing together every target lang passed in against the known plugin table'
    set -l targets $argv
    # data table: lang name -> plugin id. single source of truth; adding a
    # language is one row here, no other case to touch.
    set -l langs py rust cpp
    set -l plugins pyright-lsp rust-analyzer-lsp clangd-lsp
    set -l parts
    for i in (seq (count $langs))
        if contains -- $langs[$i] $targets
            set -a parts "\"$plugins[$i]@claude-plugins-official\":true"
        else
            set -a parts "\"$plugins[$i]@claude-plugins-official\":false"
        end
    end
    echo "{\"enabledPlugins\":{"(string join , $parts)"}}"
end

function __claude_ide_detect --description 'print every one of py/rust/cpp whose markers are present in cwd (one per line), or nothing if none found'
    set -l found
    if test -f Cargo.toml
        set -a found rust
    end
    if test -f pyproject.toml -o -f setup.py -o -f requirements.txt -o -f Pipfile
        set -a found py
    end
    if test -f CMakeLists.txt -o -f Makefile -o -f configure.ac
        set -a found cpp
    end
    if test (count $found) -eq 0
        set -l rs_hit (find . -maxdepth 1 -iname '*.rs' -print -quit)
        set -l py_hit (find . -maxdepth 1 -iname '*.py' -print -quit)
        set -l cpp_hit (find . -maxdepth 1 \( -iname '*.c' -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.h' -o -iname '*.hpp' \) -print -quit)
        test (count $rs_hit) -gt 0; and set -a found rust
        test (count $py_hit) -gt 0; and set -a found py
        test (count $cpp_hit) -gt 0; and set -a found cpp
    end
    for lang in $found
        echo $lang
    end
end

function __claude_ide_help --description 'print only the claude-ide extension help section'
    echo "usage: claude ide MODE [claude-args...]"
    echo ""
    echo "Launch claude with only the relevant language-server plugin(s) enabled,"
    echo "instead of all of clangd-lsp/pyright-lsp/rust-analyzer-lsp at once."
    echo ""
    echo "  py, python  only pyright-lsp enabled"
    echo "  rust        only rust-analyzer-lsp enabled"
    echo "  cpp, c      only clangd-lsp enabled"
    echo "  auto        detect any/all of py/rust/cpp from cwd markers (OR'd together)"
    echo "              + launch in safe mode"
    echo "              (disables CLAUDE.md, skills, hooks, MCP, custom themes/keybindings, etc)"
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
                command claude --settings (__claude_ide_plugin_json py) $rest
            case rust
                command claude --settings (__claude_ide_plugin_json rust) $rest
            case cpp c
                command claude --settings (__claude_ide_plugin_json cpp) $rest
            case auto
                if contains -- -h $rest; or contains -- --help $rest
                    set -l detected (__claude_ide_detect)
                    if test (count $detected) -eq 0
                        echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", would use safe mode"
                    else
                        echo "claude ide auto: would detect '"(string join , $detected)"' in "(pwd)" (with safe mode)"
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
                if test (count $detected) -eq 0
                    test $quiet -eq 0; and echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", launching safe mode" >&2
                    command claude --safe-mode $rest
                else
                    test $quiet -eq 0; and echo "claude ide auto: detected "(string join , $detected)" (safe mode)" >&2
                    command claude --settings (__claude_ide_plugin_json $detected) --safe-mode $rest
                end
            case '*'
                echo "claude ide: unknown mode '$mode' (expected: py, rust, cpp, auto)" >&2
                return 1
        end
    else
        command claude $argv
    end
end
