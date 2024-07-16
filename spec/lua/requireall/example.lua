require("requireall").execute({
  paths = function()
    return {
      "./lua/requireall/test/data/example.lua",
    }
  end,
  module_filter = function(module_path)
    if module_path:find("%.test%.helper") then
      return false
    end
    return true
  end,
})
