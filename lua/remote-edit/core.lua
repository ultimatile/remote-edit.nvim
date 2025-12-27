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

function M.get_hosts()
  -- Try to get hosts from SSH config
  local ssh_hosts = utils.parse_ssh_config()
  
  if #ssh_hosts > 0 then
    return ssh_hosts
  end
  
  -- No hosts found
  return {}
end

function M.pick_host(callback)
  local fzf = get_fzf()
  local hosts = M.get_hosts()
  
  if #hosts == 0 then
    vim.notify("remote-edit: no hosts found in ~/.ssh/config", vim.log.levels.ERROR)
    return
  end
  
  fzf.fzf_exec(hosts, {
    prompt = "host> ",
    actions = {
      ["default"] = function(selected)
        callback(selected[1])
      end,
    },
  })
end

function M.open_picker(host, opts)
  local fzf = get_fzf()
  opts = opts or {}
  
  local home, err = utils.remote_home(host)
  if not home then
    vim.notify("remote-edit: failed to get remote $HOME: " .. (err or ""), vim.log.levels.ERROR)
    return
  end
  
  -- Start fuzzy filer from home directory
  M.browse_directory(host, home)
end

function M.browse_directory(host, path)
  local fzf = get_fzf()
  
  -- List directory contents with one entry per line (preserves spaces in names)
  local stdout, _, _ = utils.ssh_run(host, ("ls -1a %q"):format(path))
  local list_output = utils.filter_ls_output(stdout, path)
  local items = vim.split(list_output, "\n", { trimempty = true })

  fzf.fzf_exec(items, {
    prompt = ("scp:%s:%s> "):format(host, path),
    preview = {
      type = "cmd",
      fn = function(items)
        local item = items[1]
        if not item or item == "" then return "" end
        local full_path = utils.join_path(path, item)
        local remote_cmd = ("if file %q; then echo; head -50 %q; else ls -la %q; fi 2>/dev/null"):format(
          full_path,
          full_path,
          full_path
        )
        return utils.ssh_cmd(host, remote_cmd)
      end,
    },
    actions = {
      ["default"] = function(selected)
        local item = selected[1]
        if not item or item == "" then return end
        
        local full_path = utils.join_path(path, item)
        
        -- Check if it's a directory
        local stdout, _, _ = utils.ssh_run(host, ("test -d %q && echo dir || echo file"):format(full_path))
        local result = stdout:gsub("%s+", "")
        
        if result == "dir" then
          -- Recursively browse directory
          M.browse_directory(host, full_path)
        else
          -- Edit file
          vim.cmd(("edit scp://%s//%s"):format(host, full_path))
        end
      end,
    },
  })
end

return M
