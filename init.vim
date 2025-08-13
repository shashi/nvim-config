call plug#begin('~/.local/share/nvim/plugged')

" LSP Support
Plug 'neovim/nvim-lspconfig'            " Better LSP config support for Neovim native LSP client
Plug 'williamboman/mason.nvim'          " Optional: Manage external LSP servers
Plug 'williamboman/mason-lspconfig.nvim'  " Mason integration with lspconfig

" Completion (lightweight)
Plug 'hrsh7th/nvim-cmp'                 " Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'            " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-buffer'              " Buffer source for nvim-cmp

" FZF fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"Cal
Plug 'itchyny/calendar.vim'

" Syntax highlighting collection
Plug 'sheerun/vim-polyglot'

" Colorscheme
Plug 'morhetz/gruvbox'
Plug 'dense-analysis/ale'

Plug 'nvim-lua/plenary.nvim'

call plug#end()

" Set leader key to space (must be before any leader mappings)
let mapleader = " "

" linting and language support
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'elixir': ['mix_format'],
\   'python': ['black', 'ruff']
\}

let g:ale_fix_on_save = 1
let g:ale_enabled = 0  " Start with ALE disabled for performance

" LSP mappings (we'll configure these in lua)
nmap <silent> gd :lua vim.lsp.buf.definition()<CR>
nmap <silent> gr :lua vim.lsp.buf.references()<CR>
nmap <silent> K :lua vim.lsp.buf.hover()<CR>
nmap <silent> <leader>rn :lua vim.lsp.buf.rename()<CR>
nmap <silent> <leader>ca :lua vim.lsp.buf.code_action()<CR>

" Toggle diagnostics
nmap <silent> <leader>td :lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>
nmap <silent> <leader>ti :lua ToggleInlayHints()<CR>


" Numbers & UI
set number
set relativenumber
set mouse=a
set clipboard^=unnamedplus
set cursorline
set termguicolors
set background=dark
syntax enable
filetype plugin indent on
colorscheme gruvbox

" Tabs
set tabstop=4 shiftwidth=4 expandtab

" FZF mappings
nnoremap <C-p> :Files<CR>

" Window navigation
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Quit mapping
nnoremap <C-q> :q!<CR>

" --- LSP and completion config ---
lua <<EOF
-- Setup Mason first
require("mason").setup()

-- Simple LSP setup without mason-lspconfig auto-enable
local lspconfig = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- LSP on_attach function
local on_attach = function(client, bufnr)
    -- Disable diagnostics by default
    vim.diagnostic.enable(false, { bufnr = bufnr })
    
    -- Disable inlay hints by default
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
end

-- Setup Python LSP manually
if vim.fn.executable("basedpyright-langserver") == 1 then
    lspconfig.basedpyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode = "strict",
                    autoImportCompletions = true,
                    inlayHints = {
                        variableTypes = true,
                        functionReturnTypes = true,
                        callArgumentNames = true,
                        pytestParameters = true,
                    },
                },
            },
        },
    })
end

-- Setup Elixir LSP manually
if vim.fn.isdirectory(vim.fn.expand("~/.local/share/nvim/mason/packages/elixir-ls")) == 1 then
    lspconfig.elixirls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls") },
    })
end

-- Setup nvim-cmp for completion
local cmp = require('cmp')
cmp.setup({
    enabled = false,  -- Start with completion disabled
    mapping = {
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    }
})

-- Global toggle for inlay hints
_G.inlay_hints_enabled = false

function ToggleInlayHints()
    local enabled = vim.lsp.inlay_hint.is_enabled()
    vim.lsp.inlay_hint.enable(not enabled)
    if not enabled then
        print("Inlay hints enabled")
    else
        print("Inlay hints disabled")
    end
end

-- Function to toggle completion
function ToggleCompletion()
    local current = require('cmp').config.enabled
    require('cmp').setup({ enabled = not current })
    if not current then
        print("Completion enabled")
    else
        print("Completion disabled")
    end
end

EOF

" Additional toggle commands
nmap <silent> <leader>tc :lua ToggleCompletion()<CR>
nmap <silent> <leader>ta :ALEToggle<CR>
