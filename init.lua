-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.showcmd = true
vim.o.mouse = ""

-- Getting around
vim.keymap.set('n', '<space>', '<nop>', {noremap = true})
vim.g.mapleader = ' '

-- Editing neovim
vim.keymap.set('n', '<leader>ev', '<cmd>e ~/.config/nvim/init.lua<cr>', {noremap = true})
vim.keymap.set('n', '<leader>sv', '<cmd>source ~/.config/nvim/init.lua<cr>', {noremap = true})

-- Insert mode
vim.keymap.set('i', 'jk', '<esc>', {noremap = true})
vim.keymap.set('t', 'jk', '<c-\\><c-n>', {noremap = true})
vim.keymap.set('i', 'jl', '<esc><cmd>w<cr>', {noremap = true})

-- Tabs
vim.keymap.set('n', '<m-l>', '<cmd>tabnext<cr>', {noremap = true})
vim.keymap.set('n', '<m-h>', '<cmd>tabprev<cr>', {noremap = true})
vim.keymap.set('n', '<leader>tn', '<cmd>tabnew<cr>', {noremap = true})
local function duplicateTab()
	local buf = vim.api.nvim_buf_get_number(0)
	vim.cmd("tabnew")
	vim.api.nvim_win_set_buf(0, buf)
end
vim.keymap.set('n', '<leader>td', '<cmd>lua idkyet.duplicateTab()<cr>', {noremap = true})

-- Blankspace
vim.keymap.set('n', '<leader>sws', '<cmd>set listchars=space:_,tab:>~ list<cr>', {noremap = true})
vim.keymap.set('n', '<leader>hws', '<cmd>set listchars=eol:$ nolist<cr>', {noremap = true})

-- Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local function tsInstall()
	local langs = { "go" }
	for i, lang in ipairs(langs) do
		vim.cmd("TSInstall " .. lang)
	end
end


idkyet = {
	duplicateTab = duplicateTab,
	tsInstall = tsInstall,
}

require("lazy").setup({
	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
	{ "nvim-treesitter/nvim-treesitter" },
	{ "L3MON4D3/LuaSnip" },
	{ "hrsh7th/nvim-cmp" },
	{ "nvim-telescope/telescope.nvim", dependencies = { 'nvim-lua/plenary.nvim' } },
})

-- Color

vim.cmd([[colorscheme gruvbox]])
