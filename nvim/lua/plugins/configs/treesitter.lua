require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'lua',
    'c',
    'vim',
    'vimdoc',
    'html',
    'css',
    'typescript',
    'javascript',
    'go',
    'gomod',
    'gosum',
    'gowork',
    'php',
    'json',
    'jsonc',
    'yaml',
    'toml',
    'python',
    'bash',
    'cmake',
    'dockerfile',
    'lua',
    'python',
    'scss',
    'tsx',
    'yaml',
    -- 'vtsls',
    -- 'eslint',
  },

  highlight = {
    enable = true,

    -- use_languagetree = true,
    additional_vim_regex_highlighting = false,
  },
  context_commentstring = {
    config = {
      javascript = {
        __default = '// %s',
        jsx_element = '{/* %s */}',
        jsx_fragment = '{/* %s */}',
        jsx_attribute = '// %s',
        comment = '// %s',
      },
      typescript = { __default = '// %s', __multiline = '/* %s */' },
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']]'] = '@function.outer',
        [']m'] = '@class.outer',
      },
      goto_next_end = {
        [']['] = '@function.outer',
        [']M'] = '@class.outer',
      },
      goto_previous_start = {
        ['[['] = '@function.outer',
        ['[m'] = '@class.outer',
      },
      goto_previous_end = {
        ['[]'] = '@function.outer',
        ['[M'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>s'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>S'] = '@parameter.inner',
      },
    },
  },
  -- indent = { enable = true },
}
