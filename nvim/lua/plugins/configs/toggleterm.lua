local toggleterm = require 'toggleterm'

toggleterm.setup {
  size = 20,
  -- iopen_mapping = [[<c-\>]],
  --hide_numbers = true,
  --shade_filetypes = {},
  --shade_terminals = true,
  --shading_factor = 2,
  --start_in_insert = true,
  --insert_mappings = true,
  --terminal_mappings = true,
  --persist_size = true,
  --direction = 'horizontal', -- 'vertical' | 'horizontal' | 'tab' | 'float'
  --close_on_exit = true,
  --shell = vim.o.shell,
  --float_opts = {
  --  border = 'curved',
  -- winblend = 3,
  --},
}

local function set_toggleterm_keymaps()
  local opts = { noremap = true, silent = true }
  vim.api.nvim_set_keymap('n', '<Leader>t', '<Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>gg', '<Cmd>lua _G.toggle_lazygit()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>tn', '<Cmd>lua _G.toggle_node()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>tu', '<Cmd>lua _G.toggle_gdu()<CR>', opts)
  -- golang sandbok
  vim.api.nvim_set_keymap('n', '<Leader>tg', '<Cmd>lua _G.toggle_golang()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>tp', '<Cmd>lua _G.toggle_python()<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>tf', '<Cmd>ToggleTerm direction=float<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>th', '<Cmd>ToggleTerm size=10 direction=horizontal<CR>', opts)
  vim.api.nvim_set_keymap('n', '<Leader>tv', '<Cmd>ToggleTerm size=80 direction=vertical<CR>', opts)
  vim.api.nvim_set_keymap('n', '<F7>', '<Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('t', '<F7>', '<Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('i', '<F7>', '<Esc><Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('n', "<C-'>", '<Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('t', "<C-'>", '<Cmd>ToggleTerm<CR>', opts)
  vim.api.nvim_set_keymap('i', "<C-'>", '<Esc><Cmd>ToggleTerm<CR>', opts)
end

_G.toggle_lazygit = function()
  if vim.fn.executable 'lazygit' == 1 then
    --make full save before opening lazygit
    vim.cmd 'silent wa!'
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      hidden = true,
      direction = 'float',
      on_exit = function(_, _, _)
        vim.cmd 'checktime' -- Reload current buffer
      end,
    }
    lazygit:toggle()
  else
    print 'LazyGit not found!'
  end
end

_G.toggle_golang = function()
  if vim.fn.executable 'go' == 1 then
    local Terminal = require('toggleterm.terminal').Terminal
    local golang = Terminal:new { cmd = 'go', hidden = true }
    golang:toggle()
  else
    print 'Go not found!'
  end
end

_G.toggle_node = function()
  if vim.fn.executable 'node' == 1 then
    local Terminal = require('toggleterm.terminal').Terminal
    local node = Terminal:new { cmd = 'node', hidden = true }
    node:toggle()
  else
    print 'Node not found!'
  end
end

_G.toggle_gdu = function()
  local gdu = vim.fn.has 'mac' == 1 and 'gdu-go' or 'gdu'
  if vim.fn.has 'win32' == 1 and vim.fn.executable(gdu) ~= 1 then
    gdu = 'gdu_windows_amd64.exe'
  end
  if vim.fn.executable(gdu) == 1 then
    local Terminal = require('toggleterm.terminal').Terminal
    local gdu_term = Terminal:new { cmd = gdu, hidden = true }
    gdu_term:toggle()
  else
    print(gdu .. ' not found!')
  end
end

_G.toggle_python = function()
  local python = vim.fn.executable 'python' == 1 and 'python' or vim.fn.executable 'python3' == 1 and 'python3'
  if python then
    local Terminal = require('toggleterm.terminal').Terminal
    local python_term = Terminal:new { cmd = python, hidden = true }
    python_term:toggle()
  else
    print 'Python not found!'
  end
end

set_toggleterm_keymaps()
