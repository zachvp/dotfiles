function translate --description 'look up a claude-ide string via gettext, applying printf-style %s substitution; falls back to the original text when no catalog is installed'
    set -lx TEXTDOMAIN claude-ide
    set -lx TEXTDOMAINDIR $HOME/.local/claude/locale
    set -l fmt (command gettext -- $argv[1])
    printf "$fmt\n" $argv[2..-1]
end

function __claude_ide_help --description 'print only the claude-ide extension help section'
    translate "usage: claude ide MODE [claude-args...]"
    echo ""
    translate "Launch claude with only the relevant language-server plugin(s) enabled,"
    translate "instead of all of clangd-lsp/pyright-lsp/rust-analyzer-lsp at once."
    echo ""
    translate "  py, python  only pyright-lsp enabled"
    translate "  rust        only rust-analyzer-lsp enabled"
    translate "  cpp, c      only clangd-lsp enabled"
    translate "  auto        detect any/all of py/rust/cpp from cwd markers (OR'd together)"
    translate "              + launch in safe mode"
    translate "              (disables CLAUDE.md, skills, hooks, MCP, custom themes/keybindings, etc)"
    echo ""
    translate "any [claude-args...] are forwarded to claude as-is."
    translate "note: native 'claude --bare' only supports ANTHROPIC_API_KEY/apiKeyHelper auth"
    translate "(no OAuth/keychain), so it won't authenticate under a Pro/Max subscription."
    echo ""
    translate "pass -v/--verbose alongside -h/--help to also print vanilla 'claude --help' below this."
end

function __claude_wrapper_banner --description 'small banner marking this as our custom wrapper over the real claude CLI'
    set_color -o cyan
    translate "◆ %s — custom wrapper over Claude Code" (claude-ide banner-name)
    set_color normal
end

function __claude_ide_maybe_print_vanilla_help --description 'if -v/--verbose is present, print vanilla claude --help below the current output'
    if contains -- -v $argv; or contains -- --verbose $argv
        echo ""
        translate "--- vanilla claude --help ---"
        echo ""
        command claude --help
    end
end

# single source of truth for the auto-mode decision tree (in-config-dir? ->
# else detect langs), so the -h/--help preview and the real dispatch can't
# drift apart. prints "config" alone, or "safe" followed by one detected lang
# per line (possibly none).
function __claude_ide_auto_status --description 'compute the auto-mode decision once: config-dir skip, or safe-mode + detected langs'
    if claude-ide in-config-dir
        echo config
    else
        echo safe
        claude-ide detect
    end
end

# all detect/plugin-json/safe-mode logic lives in claude-ide (~/.local/bin),
# shared across shells — this function is just the fish-side dispatch.
#
# every branch builds up a $flags list instead of dispatching `command claude`
# directly, so there's a single call site at the bottom — a new default flag
# (e.g. --exclude-dynamic-system-prompt-sections below) is a one-line add,
# not a per-branch edit.
function claude --description 'claude, with an "ide" subcommand for scoped-plugin sessions'
    if test "$argv[1]" = "ide"
        set -l mode $argv[2]
        set -l rest $argv[3..-1]
        set -l flags --exclude-dynamic-system-prompt-sections
        switch $mode
            case '' -h --help
                __claude_ide_help
                __claude_ide_maybe_print_vanilla_help $rest
                return 0
            case py python rust cpp c
                switch $mode
                    case python
                        set mode py
                    case c
                        set mode cpp
                end
                set -a flags --settings (claude-ide plugin-json $mode)
            case auto
                if contains -- -h $rest; or contains -- --help $rest
                    set -l auto_status (__claude_ide_auto_status)
                    if test "$auto_status[1]" = config
                        translate "claude ide auto: in Claude Code config dir (%s), would skip safe mode" "$HOME/.claude"
                    else
                        set -l detected $auto_status[2..-1]
                        if test (count $detected) -eq 0
                            translate "claude ide auto: no py/rust/cpp markers found in %s, would use safe mode" (pwd)
                        else
                            translate "claude ide auto: would detect '%s' in %s (with safe mode)" (string join , $detected) (pwd)
                        end
                    end
                    translate "(pass -v/--verbose alongside -h/--help to also print vanilla claude --help)"
                    __claude_ide_maybe_print_vanilla_help $rest
                    return 0
                end
                set -l quiet 0
                contains -- -v $rest; and set quiet 1
                contains -- --version $rest; and set quiet 1
                set -l auto_status (__claude_ide_auto_status)
                if test "$auto_status[1]" = config
                    test $quiet -eq 0; and translate "claude ide auto: in Claude Code config dir, skipping safe mode" >&2
                else
                    set -a flags --safe-mode
                    set -l detected $auto_status[2..-1]
                    if test (count $detected) -eq 0
                        test $quiet -eq 0; and translate "claude ide auto: no py/rust/cpp markers found in %s, launching safe mode" (pwd) >&2
                    else
                        test $quiet -eq 0; and translate "claude ide auto: detected %s (safe mode)" (string join , $detected) >&2
                        set -a flags --settings (claude-ide plugin-json $detected)
                    end
                end
            case '*'
                translate "claude ide: unknown mode '%s' (expected: py, rust, cpp, auto)" "$mode" >&2
                return 1
        end
        command claude $flags $rest
    else
        __claude_wrapper_banner
        command claude --exclude-dynamic-system-prompt-sections $argv
    end
end
