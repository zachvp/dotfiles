function claude-cpp --description 'Claude Code with only clangd-lsp enabled'
    claude --settings '{"enabledPlugins":{"clangd-lsp@claude-plugins-official":true,"pyright-lsp@claude-plugins-official":false,"rust-analyzer-lsp@claude-plugins-official":false}}' $argv
end
