describe("remote-edit.core", function()
  local core = require("remote-edit.core")
  
  describe("pick_host", function()
    it("exists and is callable", function()
      assert.is_function(core.pick_host)
    end)
    
    -- Note: Actual fzf testing requires interactive environment
    -- Manual testing needed for full functionality
  end)
  
  describe("open_picker", function()
    it("exists and is callable", function()
      assert.is_function(core.open_picker)
    end)
    
    -- Note: Requires SSH connection and fzf-lua
    -- Manual testing needed for full functionality
  end)
end)
