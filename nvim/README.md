# Vim files

## Dependencies

Requires **Neovim 0.11+**. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which installs itself on first start.

Installing treesitter parsers requires the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) and a C compiler, e.g. **Visual Studio Build Tools 2022**, see [nvim-treesitter requirements](https://github.com/nvim-treesitter/nvim-treesitter/tree/main#requirements).

The C# language server (Roslyn) and debugger (netcoredbg) are installed through Mason and require the **.NET SDK** (`dotnet` on the `PATH`).

The database UI ([vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui)) runs queries through each database's CLI, which must be on the `PATH`: `sqlcmd` for SQL Server, `psql` for PostgreSQL, `sqlite3` for SQLite.

## Installation
Link the folder to `~/AppData/Local/nvim/` so changes are tracked by this repository.

`New-Item -ItemType Junction -Path ~\AppData\Local\nvim -Target $PWD`
