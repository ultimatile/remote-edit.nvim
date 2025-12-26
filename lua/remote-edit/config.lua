---@class RemoteEditConfig
---@field hosts table
---@field find_maxdepth number
---@field find_extra string

local M = {}

M.defaults = {
  hosts = {},
  find_maxdepth = 2,
  find_extra = "",
}

---@type RemoteEditConfig
M.current = {}

---@param config RemoteEditConfig
M.setup = function(config)
  M.current = config
end

return M
