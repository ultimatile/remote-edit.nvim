---@class RemoteEditConfig
---@field hosts table
---@field find RemoteEditFindConfig

---@class RemoteEditFindConfig
---@field maxdepth number
---@field exclude string

local M = {}

M.defaults = {
  hosts = {},
  find = {
    maxdepth = 2,
    exclude = ""
  }
}

---@type RemoteEditConfig
M.current = {}

---@param config RemoteEditConfig
M.setup = function(config)
  M.current = vim.tbl_deep_extend("force", M.defaults, config)
end

return M
