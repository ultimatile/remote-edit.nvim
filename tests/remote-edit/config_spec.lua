describe("remote-edit.config", function()
  local config = require("remote-edit.config")
  
  it("has default configuration", function()
    assert.is_table(config.defaults)
    assert.is_table(config.defaults.hosts)
    assert.is_number(config.defaults.find_maxdepth)
    assert.is_string(config.defaults.find_extra)
  end)
  
  it("can setup configuration", function()
    local test_config = { hosts = {"user@test"} }
    config.setup(test_config)
    assert.same(test_config, config.current)
  end)
end)
