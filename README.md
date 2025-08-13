A minimal, fast Neovim configuration with on-demand Python type checking and LSP features.

## Philosophy

This config prioritizes speed by disabling heavy features by default. Everything can be toggled on when needed:
- Type annotations (inlay hints)
- Error checking (diagnostics)
- Auto-completion
- Linting/formatting

## Features

- **Plugin Manager**: vim-plug (lightweight and fast)
- **LSP Support**: Native nvim-lspconfig with basedpyright for Python
- **Fuzzy Finding**: fzf integration
- **Linting**: ALE with black/ruff for Python
- **Colorscheme**: Gruvbox dark
- **Languages**: Python (with type hints), Elixir

## Key Mappings

Leader key is set to `<Space>`.

### Toggles (Everything starts OFF)
- `<Space>ti` - Toggle inlay hints (type annotations)
- `<Space>td` - Toggle diagnostics (errors/warnings)
- `<Space>tc` - Toggle completion
- `<Space>ta` - Toggle ALE linting

### Navigation
- `<C-p>` - Fuzzy find files
- `<C-j/k/h/l>` - Window navigation
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show documentation
- `<Space>rn` - Rename symbol
- `<Space>ca` - Code actions

## Installation

1. Install Neovim (0.8+ required for native LSP)

2. Clone this config:
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. Install vim-plug:
   ```bash
   curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   ```

4. Open Neovim and install plugins:
   ```vim
   :PlugInstall
   ```

5. Install Python LSP server:
   ```vim
   :Mason
   ```
   Then search for and install `basedpyright`

6. Install Python formatters (optional):
   ```bash
   pip install black ruff
   ```

## Usage

1. Open a Python file
2. Code is fast by default (no heavy features running)
3. When you need type checking:
   - Press `<Space>ti` to see type annotations
   - Press `<Space>td` to see errors
   - Press `<Space>tc` for auto-completion
4. Toggle features off when done to maintain speed

## Dependencies

- Neovim 0.8+
- Git
- fzf
- ripgrep (for better searching)
- Python 3.x (for Python development)
- Node.js (for LSP servers via Mason)

## Why This Config?

- **Fast**: Everything heavy is off by default
- **Minimal**: Only essential plugins
- **Modern**: Uses Neovim's native LSP
- **Flexible**: Toggle features on demand

Perfect for developers who want a fast editor that can become powerful when needed.
