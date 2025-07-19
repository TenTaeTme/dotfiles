local plugins = {
  { lazy = true, 'nvim-lua/plenary.nvim' },

  --themes
  {
    'AstroNvim/astrotheme',
    priority = 1000,
    config = true,
  },
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
  },
  {
    'catppuccin/nvim',
  },
  {
    'folke/tokyonight.nvim',
  },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = 'openai',
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-4o', -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        temperature = 0,
        max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },

  -- File tree setup
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true },
      { 'nvim-tree/nvim-web-devicons', lazy = true },
      { 'MunifTanjim/nui.nvim', lazy = true },
    },
    config = function()
      require 'plugins.configs.neotree'
    end,
  },
  -- icons, for UI related plugins
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup()
    end,
  },

  -- syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
      require 'plugins.configs.treesitter'
    end,
  },

  -- buffer + tab line
  {
    'akinsho/bufferline.nvim',
    event = 'BufReadPre',
    config = function()
      require 'plugins.configs.bufferline'
    end,
  },

  -- statusline

  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    config = function()
      require('lualine').setup {
        options = {
          theme = 'iceberg_dark',
          section_separators = { '🐧', '🐧' },
          component_separators = { '🐧', '🐧' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }
    end,
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        lsp = {
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        presets = {
          -- bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        cmdline = {
          enabled = true, -- enable the command line popup
        },
      }
    end,
  },

  -- we use cmp plugin only when in insert mode
  -- so lets lazyload it at InsertEnter event, to know all the events check h-events
  -- completion , now all of these plugins are dependent on cmp, we load them after cmp
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- cmp sources
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lua',

      -- snippets
      --list of default snippets
      'rafamadriz/friendly-snippets',

      -- -- snippets engine
      {
        'L3MON4D3/LuaSnip',
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      --
      -- autopairs , autocompletes ()[] etc
      {
        'windwp/nvim-autopairs',
        config = function()
          require('nvim-autopairs').setup()

          --  cmp integration
          local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
          local cmp = require 'cmp'
          cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end,
      },
    },
    config = function()
      require 'plugins.configs.cmp'
    end,
  },

  -- Ensure you have 'williamboman/mason.nvim' and 'williamboman/mason-lspconfig.nvim' installed
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    cmd = { 'Mason', 'MasonInstall' },
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    after = 'mason.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'ts_ls',
          -- 'ttags',
          'intelephense',
          'tailwindcss',
          'cssls',
          'templ',
          -- 'prettierd',
          -- 'prettier',
          'gopls',
        },
      }
    end,
  },

  -- lsp
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'plugins.configs.lspconfig'
    end,
  },

  -- formatting , linting
  {
    'stevearc/conform.nvim',
    lazy = true,
    config = function()
      require 'plugins.configs.conform'
    end,
  },
  {
    'numToStr/Comment.nvim',
    opts = function()
      return {
        -- mappings = {
        --   basic = true, -- Enable basic mappings
        --   extra = true, -- Enable extra mappings
        --   extended = false, -- Enable extended mappings
        -- },
        -- toggler = {
        --   line = 'gcc', -- Line-comment toggle keymap
        --   block = 'gbc', -- Block-comment toggle keymap
        -- },
        -- opleader = {
        --   line = 'gc', -- Line-comment keymap
        --   block = 'gb', -- Block-comment keymap
        -- },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
    lazy = false,
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup {}
    end,
  },
  -- indent lines
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('ibl').setup {
        indent = { char = '│' },
        scope = { char = '│', highlight = 'Comment' },
      }
    end,
  },

  -- files finder etc
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    config = function()
      require 'plugins.configs.telescope'
    end,
  },

  -- -- lazygit
  -- {
  --   'jesseduffield/lazygit',
  --   event = 'VeryLazy',
  -- },
  -- git status on signcolumn etc
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitsigns').setup()
    end,
  },
  {
    'github/copilot.vim',
    event = 'VeryLazy',
    autoStart = true,
    keys = { { '<leader>A', '<cmd>Copilot panel<cr>' } },
  },
  {
    'fatih/vim-go',
    event = 'VeryLazy',
    autoStart = true,
    config = function()
      -- vim.g.go_highlight_methods = 0
      -- vim.g.go_highlight_functions = 0
      -- vim.g.go_highlight_function_calls = 0
      -- vim.g.go_highlight_operators = 0
      -- vim.g.go_highlight_types = 0
      -- vim.g.go_highlight_build_constraints = 0
      -- vim.g.go_highlight_generate_tags = 0
      -- vim.g.go_highlight_format_strings = 0
      -- vim.g.go_highlight_chan_whitespace_error = 0 -- Ensure this does not disable other highlighting
    end,
  },
  {
    'andymass/vim-matchup',
    event = 'BufReadPost',
    -- autoStart = true,
    -- keys = { { "<leader>A", "<cmd>Copilot panel<cr>" } },
  },
  -- Add toggleterm.nvim
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require 'plugins.configs.toggleterm'
    end,
  },
  -- session management
  {
    'rmagatti/auto-session',
    config = function()
      vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
      -- vim.keymap.set('n', '<leader>p', require('auto-session.session-lens').search_session)
      require('auto-session').setup {
        pre_save_cmds = { 'Neotree close' },
        post_restore_cmds = { 'Neotree filesystem show' },
      }
    end,
  },

  {
    'goolord/alpha-nvim',
    opts = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'

      -- Set the header
      dashboard.section.header.val = {
        '███████╗██████╗ ██╗██╗  ██╗ ██╗██████╗        ██╗ ',
        '██╔════╝██╔══██╗██║██║ ██╔╝███║╚════██╗    ██╗╚██',
        '███████╗██████╔╝██║█████╔╝ ╚██║ █████╔╝    ╚═╝ ██║',
        '╚════██║██╔═══╝ ██║██╔═██╗  ██║ ╚═══██╗    ██╗ ██║',
        '███████║██║     ██║██║  ██╗ ██║██████╔╝    ╚═╝██╔╝',
        '╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝        ╚═╝ ',
      }

      -- Set the buttons
      dashboard.section.buttons.val = {
        dashboard.button('f', '  Find file', ':Telescope find_files <CR>'),
        dashboard.button('e', '  New file', ':ene <BAR> startinsert <CR>'),
        dashboard.button('p', '  Find project', ':Telescope projects <CR>'),
        dashboard.button('r', '  Recently used files', ':Telescope oldfiles <CR>'),
        dashboard.button('t', '  Find text', ':Telescope live_grep <CR>'),
        dashboard.button('c', '  Configuration', ':e $MYVIMRC <CR>'),
        dashboard.button('q', '  Quit Neovim', ':qa<CR>'),
      }

      -- Set the footer
      dashboard.section.footer.val = {
        'Neovim loaded in ' .. vim.fn.strftime '%Y-%m-%d %H:%M:%S',
      }

      -- Set the layout
      dashboard.config.layout = {
        { type = 'padding', val = vim.fn.max { 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) } },
        dashboard.section.header,
        { type = 'padding', val = 5 },
        dashboard.section.buttons,
        { type = 'padding', val = 3 },
        dashboard.section.footer,
      }

      return dashboard
    end,
    config = function(_, opts)
      local alpha = require 'alpha'
      alpha.setup(opts.config)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        desc = 'Add Alpha dashboard footer',
        once = true,
        callback = function()
          local stats = require('lazy').stats()
          local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
          opts.section.footer.val = { 'Nvim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins  in ' .. ms .. 'ms' }
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
  {
    'L3MON4D3/LuaSnip',
    config = function(plugin, opts)
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require 'luasnip'
      luasnip.filetype_extend('javascript', { 'javascriptreact' })
      luasnip.filetype_extend('typescript', { 'typescriptreact' })
      -- load snippets paths
      require('luasnip.loaders.from_vscode').lazy_load {
        paths = { vim.fn.stdpath 'config' .. '/snippets' },
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    config = function(plugin, opts)
      require('nvim-autopairs').setup {
        disable_filetype = { 'TelescopePrompt', 'vim' },
        check_ts = true, -- Enable treesitter integration
      }

      -- If you're using nvim-cmp, add the following lines to integrate nvim-autopairs with nvim-cmp
      local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
      local cmp = require 'cmp'
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },
  {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
      require('notify').setup {
        stages = 'fade',
        timeout = 5000,
        background_colour = '#000000',
        icons = {
          ERROR = '',
          WARN = '',
          INFO = '',
          DEBUG = '',
          TRACE = '',
        },
      }
      vim.notify = require 'notify'
    end,
  },
  -- {
  --   'ray-x/go.nvim',
  --   dependencies = { -- optional packages
  --     'ray-x/guihua.lua',
  --     'neovim/nvim-lspconfig',
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   config = function()
  --     require('go').setup()
  --   end,
  --   event = { 'CmdlineEnter' },
  --   ft = { 'go', 'gomod' },
  --   build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  -- },
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
  -- {
  --   'yacineMTB/dingllm.nvim',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   config = function()
  --     local system_prompt =
  --       'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
  --     local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
  --
  --     local dingllm = require 'dingllm'
  --
  --     -- Qwen-2.5:7B configuration
  --     local function qwen_replace()
  --       dingllm.invoke_llm_and_stream_into_editor({
  --         url = 'http://host.docker.internal:11434', -- Use the correct URL for your Ollama server
  --         model = 'qwen2.5:7b', -- Use the exact model name
  --         system_prompt = system_prompt,
  --         replace = true,
  --       }, nil, dingllm.handle_openai_spec_data) -- Use nil for curl_args since we are not using OpenAI API
  --     end
  --
  --     local function qwen_help()
  --       dingllm.invoke_llm_and_stream_into_editor({
  --         url = 'http://host.docker.internal:11434', -- Use the correct URL for your Ollama server
  --         model = 'qwen2.5:7b', -- Use the exact model name
  --         system_prompt = helpful_prompt,
  --         replace = false,
  --       }, nil, dingllm.handle_openai_spec_data) -- Use nil for curl_args since we are not using OpenAI API
  --     end
  --
  --     vim.keymap.set({ 'n', 'v' }, '<leader>r', qwen_replace, { desc = 'Qwen-2.5 replace mode' })
  --     vim.keymap.set({ 'n', 'v' }, '<leader>h', qwen_help, { desc = 'Qwen-2.5 help mode' })
  --   end,
  -- },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = { { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>' } },
    config = function()
      require('codecompanion').setup {
        strategies = {
          chat = {
            adapter = 'ollama',
          },
          inline = {
            adapter = 'copilot',
          },
        },
        adapters = {
          ollama = function()
            return require('codecompanion.adapters').extend('ollama', {
              env = {},
              schema = { model = { default = 'qwen2.5:7b' } },
            })
          end,
        },
      }
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup {}
    end,
  },
  {
    'oysandvik94/curl.nvim',
    cmd = { 'CurlOpen' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>cx', '<cmd>CurlOpen<cr>', desc = 'Open a new local curl requests' },
      { '<leader>co', '<cmd>CurlOpenGlobal<cr>', desc = 'Open a new global curl requests' },
      { '<leader>cc', '<cmd>CurlCreateScopedCollection<cr>', desc = 'Create a new scoped collection' },
      { '<leader>csc', '<cmd>CurlCreateScopedCollection<cr>', desc = 'Create a new scoped collection' },
      { '<leader>cgc', '<cmd>CurlCreateGlobalCollection<cr>', desc = 'Create a new global collection' },
      { '<leader>fsc', '<cmd>CurlPickScopedCollection<cr>', desc = 'Pick a scoped collection' },
      { '<leader>fgc', '<cmd>CurlPickGlobalCollection<cr>', desc = 'Pick a global collection' },
    },
    config = function()
      local curl = require 'curl'
      curl.setup {}
    end,
  },
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle', -- Command to trigger the plugin
    keys = {
      {
        '<leader>u', -- Your preferred hotkey
        '<cmd>UndotreeToggle<cr>',
        desc = 'Toggle Undotree',
      },
    },
    config = function()
      -- Configuration options (equivalent to opts for plugins that use vim.g)
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 2 -- 2 = vertical split, 3 = horizontal
      vim.g.undotree_ShortIndicators = 1 -- Compact view
    end,
  },
}

require('lazy').setup(plugins, require 'lazy_config')
