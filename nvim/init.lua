require("options")
require("mappings")
require("commands")

-- bootstrap plugins & lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- path where its going to be installed

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("plugins")
require("highlight_yank").setup()

vim.cmd("colorscheme astrodark")
-- vim.api.nvim_set_hl(0, 'Character', { fg = '#f5983a', ctermfg = 'green' })
vim.cmd("highlight Character ctermfg=green guifg=#f5983a")
-- vim.cmd 'colorscheme gruvbox-material'
vim.opt.clipboard:append("unnamedplus")

vim.g.clipboard = {
	name = "WslClipboard",
	copy = {
		["+"] = "clip.exe",
		["*"] = "clip.exe",
	},
	paste = {
		["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r`n","`n"))',
		["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r`n","`n"))',
	},
	cache_enabled = false,
}
