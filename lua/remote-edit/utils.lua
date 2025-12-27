local M = {}

-- Run ssh command and return stdout only (stderr separated)
function M.ssh_run(host, remote_sh)
  local res = vim.system(
    { "ssh", "-T", "-q", "-o", "BatchMode=yes", host, remote_sh },
    { text = true }
  ):wait()
  return res.stdout or "", res.stderr or "", res.code
end

-- Legacy: returns command string for preview (fzf needs shell command)
function M.ssh_cmd(host, remote_sh)
  return ("ssh -T -q -o BatchMode=yes %s %s 2>/dev/null"):format(host, vim.fn.shellescape(remote_sh))
end

function M.remote_home(host)
  local stdout, stderr, code = M.ssh_run(host, 'printf "__REMOTE_HOME__%s\\n" "$HOME"')
  if code ~= 0 then
    return nil, stderr
  end

  for line in stdout:gmatch("[^\n]+") do
    local home = line:match("^__REMOTE_HOME__(/[^%s:]+)$")
    if home then
      return home, nil
    end
  end

  return nil, "Could not extract home directory from: " .. stdout
end

function M.build_find_command(home, opts)
  opts = opts or {}
  local maxdepth = opts.maxdepth or 3
  local exclude = opts.exclude or ""
  
  -- Basic find with common exclusions
  local cmd = ("find %q -maxdepth %d -type f"):format(home, maxdepth)
  
  -- Add common exclusions by default
  cmd = cmd .. " \\( -name '.*' -o -name '*.log' -o -name '*.tmp' \\) -prune -o -type f -print"
  
  if exclude ~= "" then
    cmd = cmd .. " " .. exclude
  end
  
  cmd = cmd .. " 2>/dev/null"
  return cmd
end

function M.filter_ssh_output(output)
  -- Keep only lines that look like valid file paths
  local lines = vim.split(output, "\n")
  local filtered = {}
  
  for _, line in ipairs(lines) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    -- Keep lines that are valid absolute paths (start with / and contain valid path characters)
    if trimmed:match("^/[%w%._/-]+$") then
      table.insert(filtered, trimmed)
    end
  end
  
  return table.concat(filtered, "\n")
end

function M.parse_ssh_config()
  local ssh_config_path = vim.fn.expand("~/.ssh/config")
  
  if vim.fn.filereadable(ssh_config_path) == 0 then
    return {}
  end
  
  local hosts = {}
  local lines = vim.fn.readfile(ssh_config_path)
  
  for _, line in ipairs(lines) do
    -- Match "Host hostname" (case insensitive)
    local host = line:match("^%s*[Hh]ost%s+([^%s#]+)")
    if host and host ~= "*" then
      -- Skip wildcards and add valid hostnames
      if not host:match("[*?]") then
        table.insert(hosts, host)
      end
    end
  end
  
  return hosts
end

function M.filter_ls_output(output, current_path)
  local lines = vim.split(output, "\n")
  local filtered = {}
  
  for _, line in ipairs(lines) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    -- Skip empty lines and current/parent directory entries
    if trimmed ~= "" then
      -- ls -1a should never return '/' in a filename; drop noisy lines from shells
      local is_shell_noise = trimmed:match("command not found")
        or trimmed:match("syntax error")
        or trimmed:match(": line %d+")
        or trimmed:match("No such file or directory")
      if trimmed ~= "." and trimmed ~= ".." and not trimmed:find("/") and not is_shell_noise then
        table.insert(filtered, trimmed)
      end
    end
  end
  
  return table.concat(filtered, "\n")
end

function M.join_path(base, item)
  if base:sub(-1) == "/" then
    return base .. item
  else
    return base .. "/" .. item
  end
end

return M
