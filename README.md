# .Files

Windows dotfiles. Each config is linked from its expected location into this repository, so edits are tracked here.

| Folder | Link | Target |
|---|---|---|
| `nvim` | Junction | `~\AppData\Local\nvim` (see [nvim/README.md](nvim/README.md)) |
| `powershell/Microsoft.PowerShell_profile.ps1` | Symlink | `$PROFILE` |
| `powershell/minimal.omp.json` | Symlink | `~\minimal.omp.json` |
| `powershell/modules/*` | Symlink | `~\Documents\PowerShell\Modules\*` |
| `git/.gitconfig`, `git/.gitignore_global` | Symlink | `~\` |
| `terminal/settings.json` | Symlink | `~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` |
| `agents/AGENTS.md` | Symlink | `~\AGENTS.md` |
| `agents/CLAUDE.md` | Symlink | `~\.claude\CLAUDE.md` |
| `jetBrains/riderSettings.jar` | Import | Rider settings (File > Manage IDE Settings > Import Settings) |
| `jetBrains/.ideavimrc` | Symlink | `~\.ideavimrc` |

Symlink from an elevated shell or with Developer Mode on:

`New-Item -ItemType SymbolicLink -Path $PROFILE -Target $PWD\powershell\Microsoft.PowerShell_profile.ps1`

`util-functions` has a module manifest (`util-functions.psd1`), which PowerShell loads from `~\Documents\PowerShell\Modules\util-functions`.

`agents/AGENTS.md` points agents to the [Microsoft Learn MCP server](https://learn.microsoft.com/api/mcp). Add it to Claude Code once per machine:

`claude mcp add --transport http --scope user microsoft-learn https://learn.microsoft.com/api/mcp`

## Windows Terminal

`alt+enter`, `f11` and `ctrl+shift+space` are unbound so they reach Neovim (code actions, debugger step into, LSP completion). `ctrl+v` is left to the running app: Neovim gets `<C-v>` (visual block) and PSReadLine pastes.

## Machine-local settings

Kept out of the repository:

- `~\.gitconfig.local`: git `[user]` and other per-machine settings.
- `profile.local.ps1` next to `$PROFILE`: per-machine PowerShell additions.

## Dependencies

[CaskaydiaCove Nerd Font](https://www.nerdfonts.com) (Windows Terminal font; icons for the prompt, Terminal-Icons and Neovim), [oh-my-posh](https://ohmyposh.dev), [posh-git](https://github.com/dahlbyk/posh-git), [Terminal-Icons](https://github.com/devblackops/Terminal-Icons), [delta](https://github.com/dandavison/delta) (git pager) and [bat](https://github.com/sharkdp/bat) (`cat`).
