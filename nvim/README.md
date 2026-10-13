# Neovim

## Dependencies

Requires **Neovim 0.12+**. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which installs itself on first start.

Installing treesitter parsers requires the [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md) and a C compiler, e.g. **Visual Studio Build Tools 2022**, see [nvim-treesitter requirements](https://github.com/nvim-treesitter/nvim-treesitter/tree/main#requirements).

Search everywhere requires [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg` on the `PATH`). [telescope-fzf-native](https://github.com/nvim-telescope/telescope-fzf-native.nvim) is built with **CMake** (included in Visual Studio Build Tools) and is skipped when `cmake` is not on the `PATH`.

The C# language server (Roslyn) and debugger (netcoredbg) are installed through Mason and require the **.NET SDK** (`dotnet` on the `PATH`).

The TypeScript/JavaScript (`vtsls`), ESLint, CSS, JSON and YAML language servers and the Prettier and Biome formatters are installed through Mason and require **Node.js** (`npm` on the `PATH`). JSON and YAML files get schemas by file name from [SchemaStore](https://www.schemastore.org) (appsettings.json, package.json, Azure Pipelines, ...). XML is handled by lemminx, which Mason installs with its own Java runtime, including `.csproj`, `.fsproj`, `.props` and `.targets` files (tag completion, well-formedness errors and formatting, no MSBuild-specific completion).

Files are formatted on save and with `<Leader>rc` through [conform.nvim](https://github.com/stevearc/conform.nvim): stylua for Lua, Biome for JS/TS/CSS when the project has a `biome.json` and Prettier otherwise. Other filetypes, e.g. C#, PowerShell, SQL, JSON, YAML and XML, are formatted by their language server. In projects with an ESLint config, ESLint's fixes are applied before saving.

SQL Server support ([mssql.nvim](https://github.com/Kurren123/mssql.nvim), `<Leader>db`) downloads Microsoft's SQL Tools Service on first start. Connections are kept in a JSON file opened with `<Leader>dbe`. `<Leader>dbc` picks a connection, opening a query buffer when needed. `<Leader>dbf` lists tables, views and procedures, and `<C-CR>` runs the statement under the cursor.

## Installation
Link the folder to `~/AppData/Local/nvim/` so changes are tracked by this repository.

`New-Item -ItemType Junction -Path ~\AppData\Local\nvim -Target $PWD`
