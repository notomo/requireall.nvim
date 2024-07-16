local M = {}

function M.func1()
  require("requireall.invalid")
end

function M.func2()
  require("requireall")
end

function M.func3()
  require("requireall.test.helper")
end

return M
