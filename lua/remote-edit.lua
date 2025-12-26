local config = require("remote-edit.config")
local core = require("remote-edit.core")

---@class RemoteEdit
local M = {}

---@type RemoteEditConfig
M.config = config.defaults

---@param opts RemoteEditConfig?
M.setup = function(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  config.setup(M.config)
  
  vim.api.nvim_create_user_command("Redit", function(cmdopts)
    local arg = cmdopts.args and cmdopts.args:match("^%s*(.-)%s*$") or ""
    if arg ~= "" then
      core.open_picker(arg)
    else
      core.pick_host(core.open_picker)
    end
  end, { nargs = "?" })
end

return M
