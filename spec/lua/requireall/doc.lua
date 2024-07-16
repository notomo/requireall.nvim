local util = require("genvdoc.util")
local plugin_name = vim.env.PLUGIN_NAME
local full_plugin_name = plugin_name .. ".nvim"

local example_path = ("./spec/lua/%s/example.lua"):format(plugin_name)
local job = vim.system({ "nvim", "--headless", ("+luafile %s"):format(example_path) }, { text = true }):wait()
local example_output = job.stderr

require("genvdoc").generate(full_plugin_name, {
  source = { patterns = { ("lua/%s/init.lua"):format(plugin_name) } },
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "function" then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "STRUCTURE",
      group = function(node)
        if node.declaration == nil or node.declaration.type ~= "class" then
          return nil
        end
        return "STRUCTURE"
      end,
    },
    {
      name = "EXAMPLES",
      body = function()
        return util.help_code_block_from_file(example_path) .. "\n\n" .. util.help_code_block(example_output)
      end,
    },
  },
})

local gen_readme = function()
  local exmaple = util.read_all(example_path)

  local target_path = "./lua/requireall/test/data/example.lua"
  local target_file = util.read_all(target_path)

  local content = ([[
# %s

Test `require()` calls that are included in source code.

## Example

```lua
%s```

%s
```lua
%s```

```
%s
```]]):format(full_plugin_name, exmaple, target_path, target_file, example_output)

  util.write("README.md", content)
end
gen_readme()
