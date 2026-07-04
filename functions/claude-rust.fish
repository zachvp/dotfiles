function claude-rust --description 'Claude Code with only rust-analyzer-lsp enabled'
    claude --settings '{"enabledPlugins":{"rust-analyzer-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"pyright-lsp@claude-plugins-official":false}}' $argv
end
