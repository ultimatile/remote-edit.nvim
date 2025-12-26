local core = require("remote-edit.core")

---@class RemoteEdit
local M = {}

-- Minimal setup function
M.setup = function(opts)
  -- For now, just register the command
  -- Configuration will be added later when needed
  
  vim.api.nvim_create_user_command("Redit", function(cmdopts)
    local arg = cmdopts.args and cmdopts.args:match("^%s*(.-)%s*$") or ""
    if arg ~= "" then
      -- Direct host specified: :Redit user@host
      core.open_picker(arg)
    else
      -- No host specified: :Redit (show host picker)
      core.pick_host(core.open_picker)
    end
  end, { 
    nargs = "?",
    desc = "Edit remote files via scp. Usage: :Redit [user@host]"
  })
end

return M
