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
\   'python': ['black', 'ruff'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'typescriptreact': ['prettier'],
\   'javascriptreact': ['prettier']
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
nmap <silent> <leader>td :lua ToggleDiagnostics()<CR>
nmap <silent> <leader>ti :lua ToggleInlayHints()<CR>

" Show diagnostic details
nmap <silent> <leader>e :lua vim.diagnostic.open_float()<CR>
nmap <silent> [d :lua vim.diagnostic.goto_prev()<CR>
nmap <silent> ]d :lua vim.diagnostic.goto_next()<CR>


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

" Line wrapping
set wrap
set linebreak
set showbreak=↪\ 

" Tabs
set tabstop=4 shiftwidth=4 expandtab

" File type specific settings
autocmd FileType typescript,typescriptreact,javascript,javascriptreact setlocal tabstop=2 shiftwidth=2

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

-- Configure diagnostics display
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = 'if_many',
        -- Limit the virtual text width
        format = function(diagnostic)
            local max_width = 50
            local message = diagnostic.message
            if string.len(message) > max_width then
                return string.sub(message, 1, max_width) .. '...'
            end
            return message
        end,
    },
    float = {
        source = 'always',
        border = 'rounded',
    },
})

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
local elixirls_path = vim.fn.expand("~/.local/share/nvim/mason/bin/elixir-ls")
if vim.fn.executable(elixirls_path) == 1 then
    lspconfig.elixirls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { elixirls_path },
        root_dir = lspconfig.util.root_pattern("mix.exs", ".git") or vim.fn.getcwd,
    })
end

-- Setup TypeScript LSP
local tsserver_path = vim.fn.expand("~/.local/share/nvim/mason/bin/typescript-language-server")
if vim.fn.executable(tsserver_path) == 1 or vim.fn.executable("typescript-language-server") == 1 then
    lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            },
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                }
            }
        },
    })
end

-- Setup nvim-cmp for completion
local cmp = require('cmp')
cmp.setup({
    enabled = false,  -- Start with completion disabled
    mapping = {
        ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'}),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    })
})

-- Global completion state
_G.completion_enabled = false

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
    _G.completion_enabled = not _G.completion_enabled
    require('cmp').setup({ enabled = _G.completion_enabled })
    if _G.completion_enabled then
        print("Completion enabled")
    else
        print("Completion disabled")
    end
end

-- Function to toggle diagnostics
function ToggleDiagnostics()
    local enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not enabled)
    if not enabled then
        print("Diagnostics enabled")
    else
        print("Diagnostics disabled")
    end
end

EOF

" Additional toggle commands
nmap <silent> <leader>tc :lua ToggleCompletion()<CR>
nmap <silent> <leader>ta :ALEToggle<CR>

" Debug commands
nmap <silent> <leader>lsp :LspInfo<CR>
