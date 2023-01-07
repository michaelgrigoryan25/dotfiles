:set number
:set autoindent
:set tabstop=2
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
:set clipboard+=unnamedplus
:set relativenumber
:set nowrap
:set cmdheight=2

call plug#begin()
" plenary is a utility for writing plugins. basically internal sdk which would
" exist in here
Plug 'nvim-lua/plenary.nvim'
" nvim-cmp - Autocompletion for Neovim
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" Snippet Engine for nvim-cmp
Plug 'L3MON4D3/LuaSnip'
" Neovim Telescope - Commands for finding, filtering, previewing, and picking files
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
" NERDTree - Commands for showing file tree from neovim
Plug 'preservim/nerdtree'
Plug 'ahmedkhalf/project.nvim'
" Vim Airline - Custom styles for the status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" move.nvim - Move lines vertically and horizontally
Plug 'fedepujol/move.nvim'
" CoC - Provides various language servers and features
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Live grep support in Telescope
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
" astro support for vim
Plug 'wuelnerdotexe/vim-astro'
" variable rename support in nvim like in vscode
Plug 'filipdutescu/renamer.nvim', { 'branch': 'master' }
" support for commenting out lines
Plug 'tpope/vim-commentary'
" presence plugin for discord
Plug 'andweeb/presence.nvim'
" colorscheme
Plug 'NLKNguyen/papercolor-theme'
call plug#end()

colorscheme PaperColor 

" auto formatting for c/c++ files
autocmd FileType c,cpp setlocal equalprg=clang-format

" Keybindings for move.nvim
nnoremap <silent> <A-j> :MoveLine(1)<CR>
nnoremap <silent> <A-k> :MoveLine(-1)<CR>
vnoremap <silent> <A-j> :MoveBlock(1)<CR>
vnoremap <silent> <A-k> :MoveBlock(-1)<CR>

" Keybindings for renamer.nvim
inoremap <silent> <F2> <cmd>lua require('renamer').rename()<cr>
nnoremap <silent> <leader>rn <cmd>lua require('renamer').rename()<cr>
vnoremap <silent> <leader>rn <cmd>lua require('renamer').rename()<cr>

" Keybindings for Telescope
nnoremap <silent> <C-f> :Telescope find_files<CR>
nnoremap <silent> <M-S-R> :Telescope live_grep<CR>

" Enabling autocompletion via nvim-cmp
set completeopt=menu,menuone,noselect

" Enabling Prettier as a command
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
" Shortcut for calling Prettier
nnoremap <silent> <M-S-F> :Prettier<CR>

let g:coc_node_path = '~/.nvm/versions/node/v16.17.1/bin/node'
let g:coc_global_extensions = [
		\ 'coc-json',
		\ 'coc-prettier',
		\ 'coc-docker',
		\ 'coc-typos',
		\]

" Automatically reload NERDTree
autocmd BufEnter NERD_tree_* | execute 'normal R'
" Toggle NERDTree files and folders using <space>
let NERDTreeMapActivateNode='<space>'
let NERDTreeShowHidden=1

let g:presence_auto_update=1
let g:presence_main_image='neovim'
let g:presence_neovim_image_text='The One True Text Editor'
let g:presence_editing_text        = "Editing %s"
let g:presence_file_explorer_text  = "Browsing %s"
let g:presence_git_commit_text     = "Committing changes"
let g:presence_plugin_manager_text = "Managing plugins"
let g:presence_reading_text        = "Reading %s"
let g:presence_workspace_text      = "Working on %s"
let g:presence_line_number_text    = "Line %s out of %s"

lua << EOF
	require("project_nvim").setup {}
	require("telescope").load_extension("projects")
	require("telescope").load_extension("live_grep_args")

  local telescope = require("telescope")
  local lga_actions = require("telescope-live-grep-args.actions")
  
  telescope.setup {
    pickers = {
  			find_files = {
  					hidden = true
  			}
    },
    extensions = {
      live_grep_args = {
        auto_quoting = true, -- enable/disable auto-quoting
        -- override default mappings
        -- default_mappings = {},
        mappings = { -- extend mappings
          i = {
            ["<C-k>"] = lga_actions.quote_prompt(),
          }
        }
      }
    }
  }

  local actions = require("telescope.actions")
  require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    }
  })

  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },

    window = {
  		completion = cmp.config.window.bordered(),
	  	documentation = cmp.config.window.bordered(),
    },

    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
		  -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),

		sources = cmp.config.sources({{ name = 'nvim_lsp' }, { name = 'luasnip' }, {}})
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({{ name = 'path' }, { name = 'cmdline' }})
  })

	local mappings_utils = require('renamer.mappings.utils')
require('renamer').setup {
    -- The popup title, shown if `border` is true
    title = 'Rename',
    -- The padding around the popup content
    padding = {
        top = 0,
        left = 0,
        bottom = 0,
        right = 0,
    },
    -- The minimum width of the popup
    min_width = 15,
    -- The maximum width of the popup
    max_width = 45,
    -- Whether or not to shown a border around the popup
    border = true,
    -- The characters which make up the border
    border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    -- Whether or not to highlight the current word references through LSP
    show_refs = true,
    -- Whether or not to add resulting changes to the quickfix list
    with_qf_list = true,
    -- Whether or not to enter the new name through the UI or Neovim's `input`
    -- prompt
    with_popup = true,
    -- The keymaps available while in the `renamer` buffer. The example below
    -- overrides the default values, but you can add others as well.
    mappings = {
        ['<c-i>'] = mappings_utils.set_cursor_to_start,
        ['<c-a>'] = mappings_utils.set_cursor_to_end,
        ['<c-e>'] = mappings_utils.set_cursor_to_word_end,
        ['<c-b>'] = mappings_utils.set_cursor_to_word_start,
        ['<c-c>'] = mappings_utils.clear_line,
        ['<c-u>'] = mappings_utils.undo,
        ['<c-r>'] = mappings_utils.redo,
    },
    -- Custom handler to be run after successfully renaming the word. Receives
    -- the LSP 'textDocument/rename' raw response as its parameter.
    handler = nil,
}
EOF
