function claude-py --description 'Claude Code with only pyright-lsp enabled'
    claude --settings '{"enabledPlugins":{"pyright-lsp@claude-plugins-official":true,"clangd-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $argv
end
