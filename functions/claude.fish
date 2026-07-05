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

function __claude_wrapper_banner --description 'small banner marking this as our custom wrapper over the real claude CLI'
    set_color -o cyan
    echo "◆ "(claude-ide banner-name)" — custom wrapper over Claude Code"
    set_color normal
end

# all detect/plugin-json/safe-mode logic lives in claude-ide (~/.local/bin),
# shared across shells — this function is just the fish-side dispatch.
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
                command claude --settings (claude-ide plugin-json py) $rest
            case rust
                command claude --settings (claude-ide plugin-json rust) $rest
            case cpp c
                command claude --settings (claude-ide plugin-json cpp) $rest
            case auto
                if contains -- -h $rest; or contains -- --help $rest
                    if claude-ide in-config-dir
                        echo "claude ide auto: in Claude Code config dir ($HOME/.claude), would skip safe mode"
                    else
                        set -l detected (claude-ide detect)
                        if test (count $detected) -eq 0
                            echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", would use safe mode"
                        else
                            echo "claude ide auto: would detect '"(string join , $detected)"' in "(pwd)" (with safe mode)"
                        end
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
                set -l quiet 0
                contains -- -v $rest; and set quiet 1
                contains -- --version $rest; and set quiet 1
                if claude-ide in-config-dir
                    test $quiet -eq 0; and echo "claude ide auto: in Claude Code config dir, skipping safe mode" >&2
                    command claude $rest
                    return 0
                end
                set -l detected (claude-ide detect)
                if test (count $detected) -eq 0
                    test $quiet -eq 0; and echo "claude ide auto: no py/rust/cpp markers found in "(pwd)", launching safe mode" >&2
                    command claude --safe-mode $rest
                else
                    test $quiet -eq 0; and echo "claude ide auto: detected "(string join , $detected)" (safe mode)" >&2
                    command claude --settings (claude-ide plugin-json $detected) --safe-mode $rest
                end
            case '*'
                echo "claude ide: unknown mode '$mode' (expected: py, rust, cpp, auto)" >&2
                return 1
        end
    else
        __claude_wrapper_banner
        command claude $argv
    end
end
