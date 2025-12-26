local utils = require("remote-edit.utils")

local M = {}

-- Lazy check for fzf-lua (only when actually used)
local function get_fzf()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    error("remote-edit requires fzf-lua plugin. Install with your plugin manager.")
  end
  return fzf
end

-- Temporary hardcoded hosts for testing
local test_hosts = {"user@example.com", "admin@server.local"}

function M.pick_host(callback)
  local fzf = get_fzf()
  
  if #test_hosts == 0 then
    vim.notify("remote-edit: no hosts configured", vim.log.levels.ERROR)
    return
  end
  
  fzf.fzf_exec(test_hosts, {
    prompt = "host> ",
    actions = {
      ["default"] = function(selected)
        callback(selected[1])
      end,
    },
  })
end

function M.open_picker(host)
  local fzf = get_fzf()
  
  local home, err = utils.remote_home(host)
  if not home then
    vim.notify("remote-edit: failed to get remote $HOME: " .. (err or ""), vim.log.levels.ERROR)
    return
  end
  
  -- Simple find command (hardcoded for now)
  local find_cmd = ("find %q -maxdepth 2 -type f 2>/dev/null"):format(home)
  local list_cmd = utils.ssh_cmd(host, find_cmd)
  
  fzf.fzf_exec(list_cmd, {
    prompt = ("scp:%s> "):format(host),
    preview = {
      type = "cmd",
      cmd = function(path)
        return utils.ssh_cmd(host, ('sed -n "1,200p" %q'):format(path))
      end,
    },
    actions = {
      ["default"] = function(selected)
        local path = selected[1]
        if not path or path == "" then return end
        vim.cmd(("edit scp://%s//%s"):format(host, path))
      end,
    },
  })
end

return M
