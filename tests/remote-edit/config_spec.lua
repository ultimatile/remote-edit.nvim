describe("remote-edit.config", function()
  local config = require("remote-edit.config")

  it("has default configuration", function()
    assert.is_table(config.defaults)
    assert.is_table(config.defaults.hosts)
    assert.is_table(config.defaults.find)
    assert.is_number(config.defaults.find.maxdepth)
    assert.is_string(config.defaults.find.exclude)
  end)

  it("can setup configuration", function()
    local test_config = { hosts = { "user@test" } }
    config.setup(test_config)
    assert.is_table(config.current.hosts)
    assert.same("user@test", config.current.hosts[1])
    assert.is_table(config.current.find)
  end)
end)
