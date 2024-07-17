local helper = require("requireall.test.helper")
local requireall = helper.require("requireall")

describe("requireall.list()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("returns found require() info", function()
    local path = helper.test_data:create_file(
      "test.lua",
      [=[
require("requireall")
]=]
    )

    local got = requireall.list({
      paths = function()
        return { path }
      end,
    })

    assert.equals(path, got[1].path)
    assert.equals(
      [=[
require("requireall")
]=],
      got[1].source
    )
    assert.equals("requireall", got[1].matches[1].name)
  end)

  it("can use string sources", function()
    local got = requireall.list({
      paths = function()
        return {}
      end,
      sources = function()
        return {
          [[
require("requireall")
]],
        }
      end,
    })

    assert.is_nil(got[1].path)
    assert.equals(
      [=[
require("requireall")
]=],
      got[1].source
    )
    assert.equals("requireall", got[1].matches[1].name)
  end)
end)

describe("requireall.execute()", function()
  before_each(function()
    helper.before_each()
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function() end
  end)
  after_each(function()
    _G._test_error = nil
    _G._success = nil
    helper.after_each()
  end)

  it("calls found all require()", function()
    local path = helper.test_data:create_file(
      "test.lua",
      [=[
require("requireall.test.data.success")
]=]
    )

    local got_ok
    requireall.execute({
      paths = function()
        return { path }
      end,
      exit = function(ok)
        got_ok = ok
      end,
    })

    assert.equals(true, got_ok)
    assert.equals(true, _G._success)
  end)

  it("show errors", function()
    _G._test_error = true

    local messages = {}
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg)
      table.insert(messages, msg)
    end

    local path = helper.test_data:create_file(
      "test.lua",
      [=[
require("requireall.test.data.error1")
require("requireall.test.data.error2")
require("requireall.test.data.success")
]=]
    )

    local got_ok
    requireall.execute({
      paths = function()
        return { path }
      end,
      exit = function(ok)
        got_ok = ok
      end,
    })

    assert.equals(false, got_ok)
    assert.equals(true, _G._success)
    assert.is_same({
      "[requireall] path: " .. helper.test_data:relative_path("test.lua"),
      "[requireall] calling require(): requireall.test.data.error1",
      "error1",
      "[requireall] calling require(): requireall.test.data.error2",
      "error2",
      "[requireall] calling require(): requireall.test.data.success",
      [=[[requireall] errors (count: 2)
require("requireall.test.data.error1"): error1
require("requireall.test.data.error2"): error2]=],
      "",
    }, messages)
  end)

  it("can use string sources", function()
    local messages = {}
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg)
      table.insert(messages, msg)
    end

    requireall.execute({
      paths = function()
        return {}
      end,
      sources = function()
        return {
          [[
require("requireall")
]],
        }
      end,
      exit = function() end,
    })

    assert.is_same({
      [[[requireall] source: require("requireall") ...]],
      [[[requireall] calling require(): requireall]],
      "",
    }, messages)
  end)
end)
