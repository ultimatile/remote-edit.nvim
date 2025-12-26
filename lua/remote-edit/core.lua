local utils = require("remote-edit.utils")
local config = require("remote-edit.config")

local M = {}

function M.pick_host(callback)
  local fzf = require("fzf-lua")
  local hosts = config.current.hosts or {}
  
  if #hosts == 0 then
    vim.notify("remote-edit: hosts configuration is empty", vim.log.levels.ERROR)
    return
  end
  
  local display = {}
  local map = {}
  
  for _, host in ipairs(hosts) do
    local d = utils.host_display(host)
    display[#display + 1] = d
    map[d] = utils.host_value(host)
  end
  
  fzf.fzf_exec(display, {
    prompt = "host> ",
    actions = {
      ["default"] = function(selected)
        local d = selected[1]
        callback(map[d] or d)
      end,
    },
  })
end

function M.open_picker(host)
  local fzf = require("fzf-lua")
  
  local home, err = utils.remote_home(host)
  if not home then
    vim.notify("remote-edit: failed to get remote $HOME: " .. (err or ""), vim.log.levels.ERROR)
    return
  end
  
  local find_cmd = utils.build_find_command(home, config.current)
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
