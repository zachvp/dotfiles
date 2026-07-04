function claude --description 'claude, with an "ide" subcommand for scoped-plugin sessions'
    if test "$argv[1]" = "ide"
        set -l mode $argv[2]
        set -l rest $argv[3..-1]
        switch $mode
            case '' -h --help
                echo "usage: claude ide MODE [claude-args...]"
                echo ""
                echo "Launch claude with only one language-server plugin enabled,"
                echo "instead of all of clangd-lsp/pyright-lsp/rust-analyzer-lsp at once."
                echo ""
                echo "  py, python  only pyright-lsp enabled"
                echo "  rust        only rust-analyzer-lsp enabled"
                echo "  cpp, c      only clangd-lsp enabled"
                echo ""
                echo "any [claude-args...] are forwarded to claude as-is."
                echo "for zero LSP/plugin/hook overhead, use the native 'claude --bare' instead."
                return 0
            case py python
                command claude --settings '{"enabledPlugins":{"pyright-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $rest
            case rust
                command claude --settings '{"enabledPlugins":{"rust-analyzer-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"pyright-lsp@claude-plugins-official":false}}' $rest
            case cpp c
                command claude --settings '{"enabledPlugins":{"clangd-lsp@claude-plugins-official":true,"pyright-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $rest
            case '*'
                echo "claude ide: unknown mode '$mode' (expected: py, rust, cpp)" >&2
                return 1
        end
    else
        command claude $argv
    end
end
