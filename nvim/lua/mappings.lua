-- Key mappings
local map = vim.keymap.set

-- General mappings
map('n', '<C-s>', '<cmd>w<CR>')
map('i', 'jk', '<ESC>')
map('n', '<C-c>', '<cmd>%y+<CR>') -- copy whole file content

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
map('n', '<leader>fF', function()
  require('telescope.builtin').find_files { hidden = true, no_ignore = true }
end, { desc = 'Find all files' })
map('n', '<leader>fh', function()
  require('telescope.builtin').help_tags()
end, { desc = 'Find help' })
map('n', '<leader>fc', function()
  require('telescope.builtin').grep_string()
end, { desc = 'Find word under cursor' })
map('n', '<leader>fo', '<cmd>Telescope oldfiles<CR>')
-- map('n', '<leader>fw', '<cmd>Telescope live_grep<CR>')
map('n', '<leader>fw', function()
  require('telescope.builtin').live_grep {
    -- After search, send results to quickfix
    attach_mappings = function(_, map)
      map('i', '<C-q>', function(prompt_bufnr)
        require('telescope.actions').send_to_qflist(prompt_bufnr)
        vim.cmd 'copen'
      end)
      return true
    end,
  }
end, { desc = 'Live grep with quickfix' })
-- quickfix list --
map('n', '<leader>gt', '<cmd>Telescope git_status<CR>')
map('n', '<leader>n', '<cmd>cnext<CR>', { desc = 'Next quickfix item' })
map('n', '<leader>p', '<cmd>cprev<CR>', { desc = 'Previous quickfix item' })
map('n', '<leader>lo', '<cmd>copen<CR>', { desc = 'Open quickfix list' })
map('n', '<leader>lc', '<cmd>cclose<CR>', { desc = 'Close quickfix list' })

-- Comment.nvim
map('n', '<leader>/', 'gcc', { remap = true })
map('v', '<leader>/', 'gc', { remap = true })

-- Format
map('n', '<leader>fm', function()
  require('conform').format()
end)

map('n', '<C-.>', '<Cmd>ToggleTerm size=60 direction=vertical<CR>', { desc = 'Open vertical Terminal' })
map('n', '<C-,>', '<Cmd>2ToggleTerm size=60 direction=vertical<CR>', { desc = 'Open second vertical Terminal' })
map('n', '<C-/>', '<Cmd>ToggleTerm size=150 direction=vertical<CR>', { desc = 'Increase size of vertical Terminal' })
map('t', '<C-.>', '<Cmd>ToggleTerm size=60 direction=vertical<CR>', { desc = 'Open vertical Terminal' })
map('t', '<C-,>', '<Cmd>2ToggleTerm size=60 direction=vertical<CR>', { desc = 'Open second vertical Terminal' })
map('t', '<C-/>', '<Cmd>ToggleTerm size=150 direction=vertical<CR>', { desc = 'Increase size of vertical Terminal' })
map('n', 'gi', function()
  vim.lsp.buf.implementation()
end, { desc = 'Go to implementation', noremap = true })
map('n', '<Leader>ns', function()
  require('package-info').show()
end, { desc = 'Show info package' })
map('n', '<Leader>np', function()
  require('package-info').change_version()
end, { desc = 'Change version package.json' })
map('n', '<Leader>nd', function()
  require('package-info').delete()
end, { desc = 'Delete version package.json' })
map('n', '<Leader>ni', function()
  require('package-info').install()
end, { desc = 'Install version package.json' })
map('n', '<Leader>fd', function()
  require('telescope.builtin').lsp_definitions { jump_type = 'never' }
end, { desc = 'LSP definitions' })
map('n', '<Leader>aa', 'ggyG', { desc = 'Copy whole buffer' })
map('n', '<Leader>ac', 'ggdG', { desc = 'Cut whole buffer' })
map('n', '<Leader>pp', '"0p', { desc = 'Put from 0 register' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Up and center' })
map('n', '<C-d>', '<C-d>zz', { desc = 'Down and center' })
map('n', '<Leader>w', ':w!<CR>', { desc = 'Save File', silent = true })
map('n', '<Leader>q', '::wall|qa!<CR>', { desc = 'Save all and quit' })
map('n', '<leader>ft', '<cmd>TodoTelescope ketwords=TODO,FIX<cr>', { desc = 'Find todos' })

-- :TodoTelescope keywords=TODO,FIX
-- map('n', '<Leader>Q', ':wall<bar>SessionPurgeOrphaned<bar>qa!<CR>', { noremap = true, silent = true, desc = 'Save all, destroy session, and quit' })
map('n', '<Leader>Q', function()
  vim.cmd 'noa'
  vim.cmd 'wall'
  vim.cmd 'SessionPurgeOrphaned'
  vim.cmd 'SessionDelete'
  vim.cmd 'qa!'
end, { desc = 'Save all, destroy session, and quit' })

-- Bufferline
-- Close a given buffer
local function close_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local listed_buffers = vim.fn.getbufinfo { buflisted = 1 }

  if #vim.fn.getbufinfo { buflisted = 1 } < 2 then
    -- Open a new empty buffer if this is the last buffer
    vim.cmd 'enew'
    vim.cmd('bdelete ' .. bufnr)
  else
    -- Navigate to the next buffer and delete the current one
    vim.cmd 'bnext' -- Navigate to the next buffer
    vim.defer_fn(function()
      vim.cmd 'bdelete #' -- Delete the previously active buffer
    end, 1) -- Delay of 1ms
  end
end

function close_all_buffers()
  -- Open a new empty buffer
  vim.cmd 'enew'
  -- Get the list of all buffers
  local buffers = require('bufferline').get_elements().elements

  -- Close each buffer except the new empty one
  for _, e in ipairs(buffers) do
    vim.schedule(function()
      vim.cmd('bd ' .. e.id)
    end)
  end
end

-- Key mapping to close a single buffer
map('n', '<Leader>bx', function()
  close_buffer()
end, { noremap = true, silent = false, desc = 'Close buffer' })
map('n', '<C-x>', function()
  close_buffer()
end, { noremap = true, silent = false, desc = 'Close buffer' })

map('n', '<Leader>bC', function()
  close_all_buffers()
end, { noremap = true, silent = false, desc = 'Close buffer' })

-- Key mapping to close all buffers
vim.api.nvim_set_keymap('n', '<Leader>ba', ':lua close_all_buffers()<CR>', { noremap = true, silent = true, desc = 'Close all buffers' })

-- map('n', '<Leader>bx', function()
--   vim.cmd 'bnext' -- Navigate to the next buffer
--   vim.defer_fn(function()
--     vim.cmd 'bdelete #' -- Delete the previously active buffer
--   end, 1) -- Delay of 100ms
-- end, { desc = 'Close buffer' })

map('n', 'L', function()
  require('bufferline').cycle(1)
end, { desc = 'Next buffer' })

map('n', 'H', function()
  require('bufferline').cycle(-1)
end, { desc = 'Previous buffer' })

map('n', '<Leader>bp', function()
  require('bufferline').pick_buffer()
end, { desc = 'Pick buffer' })

map('n', '<Leader>bc', function()
  require('bufferline').close_with_pick()
end, { desc = 'Pick buffer to close' })

-- map('n', '<Leader>bx', function()
--   vim.cmd 'bd'
-- end, { desc = 'Close buffer' })

map('n', '<Leader>bc', function()
  require('bufferline').close_others()
end, { desc = 'Close other buffers' })

-- map('n', '<Leader>bC', function()
--   close_all_buffers()
-- end, { desc = 'Close all buffers' })
-- Set Vim options
vim.opt.relativenumber = true -- sets vim.opt.relativenumber vim.opt.number = true                 -- sets vim.opt.number
vim.opt.spell = false -- sets vim.opt.spell
vim.opt.signcolumn = 'auto' -- sets vim.opt.signcolumn to auto
vim.opt.wrap = false -- sets vim.opt.wrap
-- vim.opt.iskeyword:remove { '-', ',', '_' }
vim.opt.iskeyword:remove '_'
-- some_test_word

vim.g.matchup_matchparen_nomode = 'i' -- set mode to not match parenthesis in matchup

-- Diagnostic signs
vim.diagnostic.config {
  signs = {
    [vim.diagnostic.severity.ERROR] = { text = ' ' },
    [vim.diagnostic.severity.WARN] = { text = ' ' },
    [vim.diagnostic.severity.INFO] = { text = ' ' },
    [vim.diagnostic.severity.HINT] = { text = '󰌵' },
  },
}

-- Window navigation
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
-- same for terminal and i
map('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = 'Move to right window' })
map('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Move to left window' })
map('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = 'Move to below window' })
map('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = 'Move to above window' })

-- Close window
map('n', '<C-q>', '<cmd>q<CR>', { desc = 'Close window' })
map('t', '<C-q>', '<C-\\><C-n><cmd>q<CR>', { desc = 'Close window' })
