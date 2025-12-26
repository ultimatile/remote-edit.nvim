local M = {}

function M.ssh_cmd(host, remote_sh)
  return ("ssh %s %s"):format(host, vim.fn.shellescape("bash -lc " .. vim.fn.shellescape(remote_sh)))
end

function M.remote_home(host)
  local cmd = M.ssh_cmd(host, 'printf "%s" "$HOME"')
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, out
  end
  return (out:gsub("%s+$", "")), nil
end

return M
