# Shared config for every machine. OS-specific setup lives in conf.d/os-*.fish,
# which fish sources before this file.
#
# fish_add_path -g keeps PATH defined by these files; the universal
# fish_user_paths (stored per machine in fish_variables) stays empty.

# pyenv shims precede the conf.d/os-*.fish paths in PATH
set -gx PYENV_ROOT $HOME/.pyenv
if command -q pyenv
    fish_add_path -g $PYENV_ROOT/shims
    pyenv init - | source
end

# toolchains
fish_add_path -g ~/go/bin
fish_add_path -g ~/.dotnet/tools
fish_add_path -g ~/.npm-global/bin
fish_add_path -g ~/.opencode/bin

# Claude Pro billing cycle anchor (Friday 11am EDT = 15:00 UTC); used by cache-stats.sh --window since_epoch
set -gx CACHE_STATS_EPOCH "2026-06-26T15:00:00Z"

# ~/.local/bin goes last so it lands first in PATH, ahead of the conf.d/os-*.fish
# paths and the other prepends above; --move reorders it even when the launching
# env has it.
fish_add_path -g --move ~/.local/bin

# Everything above runs for every fish, so scripts and `fish -c` get the same
# env/PATH as a terminal. Claude Code's Bash tool runs bash directly
# (CLAUDE_CODE_SHELL in ~/.claude/settings.json), so it never lands here.
# The block below is for interactive shells: it prints, prompts, or costs a
# subprocess per startup.
if status is-interactive
    # direnv (per-directory env vars, e.g. GH_CONFIG_DIR scoping)
    command -q direnv; and direnv hook fish | source

    # claude-kit: claude-ide wrapper, generated at each startup from claude-kit's
    # init.lib.sh, the single source of truth across bash/zsh/fish.
    set -l claude_ide ~/developer/sol_reason/claude-kit/plugins/claude-kit/bin/claude-ide
    test -x $claude_ide; and $claude_ide init fish | source
end
