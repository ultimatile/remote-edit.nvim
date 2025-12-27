local M = {}

-- Run ssh command and return stdout only (stderr separated)
function M.ssh_run(host, remote_sh)
  local res = vim.system({ "ssh", "-T", "-q", "-o", "BatchMode=yes", host, remote_sh }, { text = true }):wait()
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

-- Extract lines with marker prefix, stripping the marker
function M.extract_marked_lines(output, marker)
  local items = {}
  for line in output:gmatch("[^\n]+") do
    local content = line:match("^" .. marker .. "(.+)$")
    if content and content ~= "." and content ~= ".." then
      table.insert(items, content)
    end
  end
  return items
end

function M.join_path(base, item)
  if base:sub(-1) == "/" then
    return base .. item
  else
    return base .. "/" .. item
  end
end

return M
