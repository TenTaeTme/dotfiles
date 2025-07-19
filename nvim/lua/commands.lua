vim.api.nvim_create_augroup('neotree', {})
vim.api.nvim_create_autocmd('UiEnter', {
  desc = 'Open Neotree automatically',
  group = 'neotree',
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd 'Neotree toggle'
    end
  end,
})

-- Format on save
local augroup = vim.api.nvim_create_augroup('ConformFormatting', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup,
  callback = function()
    require('conform').format()
  end,
})

-- Set filetype to php.html for .php files on buffer read and new file creation
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.php',
  callback = function()
    vim.bo.filetype = 'php.html'
  end,
})
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap('i', '<C-t>', 'copilot#Accept("<CR>")', { silent = true, expr = true })
-- Assuming the Lua module is named 'curl_command_runner.lua' and stored in '~/.config/nvim/lua/'
vim.api.nvim_set_keymap('n', '<C-c>', '<cmd>lua require("curl_command_runner").run_curl_command()<CR>', { noremap = true, silent = true })
--store cursor position
vim.api.nvim_create_augroup('userconfig', {})
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  group = 'userconfig',
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_user_command('MasonInstallAll', function()
  vim.cmd 'MasonInstall css-lsp html-lsp lua-language-server typescript-language-server templ stylua prettier prettierd emmet-ls goimports gofumpt iferr delve docker-compose-language-service dockerfile-language-server eslint-lsp gopls gomodifytags hadolint impl intelephense js-debug-adapter json-lsp selene tailwindcss-language-server'
end, {})

-- Map ESC to clear search highlights
vim.api.nvim_set_keymap('n', '<ESC>', ':nohlsearch<CR><ESC>', { noremap = true, silent = true })
