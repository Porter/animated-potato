local dirs = {'h', 'j', 'k', 'l'}

vim.api.nvim_set_keymap('n', '<space>', '<nop>', {noremap = true})
vim.g.mapleader = ' '

vim.api.nvim_set_keymap('n', '<leader>ev', ':vsplit ~/.config/nvim/init.lua<cr>', {noremap = true})

-- Use control+dir to move between windows.
for _, dir in ipairs(dirs) do
	vim.api.nvim_set_keymap('n', '<c-' .. dir .. '>', '<c-w>' .. dir, {noremap = true})
end


-- Leave insert mode quickly.
vim.api.nvim_set_keymap('i', 'jk', '<esc>', {noremap = true})
vim.api.nvim_set_keymap('i', 'jl', '<esc>:w<cr>', {noremap = true})

-- Tabs.
vim.api.nvim_set_keymap('n', '<c-n>', ':tabnext<cr>', {noremap = true})

function findTerminalBuffer()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) then
			success, channel = pcall(function() return vim.bo[buf].channel end)
			if success and channel ~= 0 then
				return buf
			end
		end
	end
end

function findOrCreateTerm()
	-- Look for a tab that has a window with an open buffer that has channel option set.
	for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			local buf = vim.api.nvim_win_get_buf(win)
			success, channel = pcall(function() return vim.bo[buf].channel end)
			if success and channel ~= 0 then
				return tab, buf, channel
			end
		end
	end

	-- Look at the last tab a terminal command was run. Switch to the terminal if there is only
	-- one window open.
	local tab = _G.lastTabWithTermHandle
	local buf = _G.lastTerminalBuffer
	if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
		local winCount = 0
		local win = nil
		for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
			winCount = winCount + 1
			win = w
		end

		success, channel = pcall(function() return vim.bo[buf].channel end)
		if winCount == 1 and success and channel ~= 0 then
			vim.api.nvim_exec("normal " .. tab .. "gtG", true) -- go to the tab.
			vim.api.nvim_win_set_buf(win, buf) -- set the terminal buffer
			return tab, buf, channel
		end
	end	


	-- Create a new tab, and start a terminal if neccessary.
	vim.api.nvim_exec("tabnew", true) -- create a new tab.
	buf = findTerminalBuffer()
	if buf == nil then
		vim.api.nvim_exec("terminal", true) -- start a new terminal.
		buf = vim.api.nvim_win_get_buf(0)
	end
	vim.api.nvim_win_set_buf(0, buf)
	success, channel = pcall(function() return vim.bo[buf].channel end)
	if not success then
		print("Unable to start a new terminal")
		return
	end
	return vim.api.nvim_win_get_tabpage(0), buf, channel
end

function termRun(cmd)
	tab, buf, channel = findOrCreateTerm()
	if channel ~= 0 then
		vim.fn.chansend(channel, cmd .. '\n')
		local num = vim.api.nvim_tabpage_get_number(tab)
		vim.api.nvim_exec("normal " .. num .. "gtG", true) -- go to tab #num.

		_G.lastTabWithTermHandle = tab
		_G.lastTerminalBuffer = buf
	end
end

vim.api.nvim_create_user_command("Make", [[lua termRun("cargo build")]], {})
vim.api.nvim_set_keymap('n', '<leader>bb', ':Make<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader><Up>', ':lua termRun("!!")<cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>br', ':lua termRun("cargo run")<cr>', {noremap = true})

-- copy to clipboard
vim.api.nvim_set_keymap('v', '<leader>y', [["*y:call system("echo -n " . shellescape(getreg("*")) . " | xclip -i -selection clipboard")<cr>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>fy', [[:call system("echo -n " . shellescape(getreg("%")) . " | xclip -i -selection clipboard")<cr>]], {noremap = true})
