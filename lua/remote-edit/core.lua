local utils = require("remote-edit.utils")
local config = require("remote-edit.config")

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

function M.browse_directory(host, path, show_hidden)
  local fzf = get_fzf()
  show_hidden = show_hidden or false

  -- List directory contents with marker prefix
  local ls_flag = show_hidden and "-1a" or "-1"
  local remote_cmd = ("for f in $(ls %s %q); do printf '__LS__%%s\\n' \"$f\"; done"):format(ls_flag, path)
  local stdout, _, _ = utils.ssh_run(host, remote_cmd)
  local items = utils.extract_marked_lines(stdout, "__LS__")

  local fzf_utils = require("fzf-lua.utils")
  local toggle_key = fzf_utils.neovim_bind_to_fzf(config.current.keymaps.toggle_hidden)
  fzf.fzf_exec(items, {
    prompt = ("scp:%s:%s> "):format(host, path),
    preview = {
      type = "cmd",
      fn = function(items)
        local item = items[1]
        if not item or item == "" then
          return ""
        end
        local full_path = utils.join_path(path, item)
        local remote_cmd =
          ("file %q | sed 's/^/__PRV__/'; head -50 %q 2>/dev/null | sed 's/^/__PRV__/'"):format(full_path, full_path)
        return utils.ssh_cmd(host, remote_cmd) .. " | grep '^__PRV__' | sed 's/^__PRV__//'"
      end,
    },
    actions = {
      ["default"] = function(selected)
        local item = selected[1]
        if not item or item == "" then
          return
        end

        local full_path = utils.join_path(path, item)

        -- Check if it's a directory (use marker to filter shell noise)
        local stdout, _, _ = utils.ssh_run(host, ("test -d %q && printf '\\n__TYPE__dir' || printf '\\n__TYPE__file'"):format(full_path))
        local result = stdout:match("__TYPE__(%w+)")

        if result == "dir" then
          -- Recursively browse directory
          M.browse_directory(host, full_path, show_hidden)
        else
          -- Edit file
          vim.cmd(("edit scp://%s/%s"):format(host, full_path))
        end
      end,
      [toggle_key] = function()
        M.browse_directory(host, path, not show_hidden)
      end,
    },
  })
end

return M
