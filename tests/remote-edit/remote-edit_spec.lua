describe("remote-edit", function()
  local remote_edit = require("remote-edit")

  describe("setup", function()
    it("exists and is callable", function()
      assert.is_function(remote_edit.setup)
    end)

    it("can be called without arguments", function()
      assert.has_no.errors(function()
        remote_edit.setup()
      end)
    end)

    it("registers Redit command", function()
      remote_edit.setup()

      -- Check if command exists
      local commands = vim.api.nvim_get_commands({})
      assert.is_not_nil(commands.Redit)
    end)
  end)
end)
