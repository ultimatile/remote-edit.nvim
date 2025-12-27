local core = require("remote-edit.core")
local config = require("remote-edit.config")

---@class RemoteEdit
local M = {}

-- Minimal setup function
M.setup = function(opts)
  -- Setup configuration
  config.setup(opts or {})
  
  vim.api.nvim_create_user_command("Redit", function(cmdopts)
    local arg = cmdopts.args and cmdopts.args:match("^%s*(.-)%s*$") or ""
    if arg ~= "" then
      -- Direct host specified: :Redit user@host
      core.open_picker(arg, config.current.find)
    else
      -- No host specified: :Redit (show host picker)
      core.pick_host(function(host)
        core.open_picker(host, config.current.find)
      end)
    end
  end, { 
    nargs = "?",
    desc = "Edit remote files via scp. Usage: :Redit [user@host]"
  })
end

return M
