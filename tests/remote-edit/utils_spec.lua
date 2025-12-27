describe("remote-edit.utils", function()
  local utils = require("remote-edit.utils")

  describe("ssh_cmd", function()
    it("generates correct ssh command", function()
      local result = utils.ssh_cmd("user@host", "echo test")
      assert.matches("ssh.*user@host", result)
      assert.matches("echo test", result)
    end)
  end)

  describe("remote_home", function()
    it("exists and is callable", function()
      assert.is_function(utils.remote_home)
    end)
  end)

  describe("build_find_command", function()
    it("generates find command", function()
      local result = utils.build_find_command("/home/user")
      assert.matches("find", result)
      assert.matches("/home/user", result)
    end)
  end)

  describe("parse_ssh_config", function()
    it("exists and is callable", function()
      assert.is_function(utils.parse_ssh_config)
    end)

    it("returns empty table when no config file", function()
      local original_filereadable = vim.fn.filereadable
      vim.fn.filereadable = function()
        return 0
      end

      local result = utils.parse_ssh_config()
      assert.same({}, result)

      vim.fn.filereadable = original_filereadable
    end)
  end)
end)
