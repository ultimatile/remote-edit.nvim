describe("remote-edit.utils", function()
  local utils = require("remote-edit.utils")
  
  describe("ssh_cmd", function()
    it("generates correct ssh command", function()
      local result = utils.ssh_cmd("user@host", "echo test")
      assert.matches("ssh user@host", result)
      assert.matches("bash %-lc", result)
    end)
  end)
  
  describe("remote_home", function()
    -- Note: This test requires actual SSH connection
    -- For now, just test the function exists
    it("exists and is callable", function()
      assert.is_function(utils.remote_home)
    end)
  end)
end)
