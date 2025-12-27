---@class RemoteEditConfig
---@field hosts table
---@field find RemoteEditFindConfig
---@field keymaps RemoteEditKeymaps

---@class RemoteEditFindConfig
---@field maxdepth number
---@field exclude string

---@class RemoteEditKeymaps
---@field toggle_hidden string Neovim format (e.g. "<C-h>")

local M = {}

M.defaults = {
  hosts = {},
  find = {
    maxdepth = 2,
    exclude = "",
  },
  keymaps = {
    toggle_hidden = "<C-h>",
  },
}

---@type RemoteEditConfig
M.current = {}

---@param config RemoteEditConfig
M.setup = function(config)
  M.current = vim.tbl_deep_extend("force", M.defaults, config)
end

return M
