local plenary_dir = os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
local is_not_a_directory = vim.fn.isdirectory(plenary_dir) == 0
if is_not_a_directory then
  vim.fn.system({ "git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir })
end

local fzf_lua_dir = os.getenv("FZF_LUA_DIR") or "/tmp/fzf-lua"
local fzf_not_a_directory = vim.fn.isdirectory(fzf_lua_dir) == 0
if fzf_not_a_directory then
  vim.fn.system({ "git", "clone", "https://github.com/ibhagwan/fzf-lua", fzf_lua_dir })
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_dir)
vim.opt.rtp:append(fzf_lua_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
