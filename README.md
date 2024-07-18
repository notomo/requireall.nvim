# requireall.nvim

Test `require()` calls that are included in source code.

## Example

./spec/lua/requireall/example.lua
```lua
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
```

./lua/requireall/test/data/example.lua
```lua
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
```

```
$ nvim --headless +'luafile ./spec/lua/requireall/example.lua'
[requireall] path: lua/requireall/test/data/example.lua
[requireall] calling require(): requireall.test.data.example
[requireall] calling require(): requireall.invalid
module 'requireall.invalid' not found:
	no field package.preload['requireall.invalid']
	no file './requireall/invalid.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/luajit-2.1/requireall/invalid.lua'
	no file '/usr/local/share/lua/5.1/requireall/invalid.lua'
	no file '/usr/local/share/lua/5.1/requireall/invalid/init.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/lua/5.1/requireall/invalid.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/lua/5.1/requireall/invalid/init.lua'
	no file './requireall/invalid.so'
	no file '/usr/local/lib/lua/5.1/requireall/invalid.so'
	no file '/home/notomo/workspace/neovim/.deps/usr/lib/lua/5.1/requireall/invalid.so'
	no file '/usr/local/lib/lua/5.1/loadall.so'
	no file './requireall.so'
	no file '/usr/local/lib/lua/5.1/requireall.so'
	no file '/home/notomo/workspace/neovim/.deps/usr/lib/lua/5.1/requireall.so'
	no file '/usr/local/lib/lua/5.1/loadall.so'
[requireall] calling require(): requireall
[requireall] errors (count: 1)
require("requireall.invalid"): module 'requireall.invalid' not found:
	no field package.preload['requireall.invalid']
	no file './requireall/invalid.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/luajit-2.1/requireall/invalid.lua'
	no file '/usr/local/share/lua/5.1/requireall/invalid.lua'
	no file '/usr/local/share/lua/5.1/requireall/invalid/init.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/lua/5.1/requireall/invalid.lua'
	no file '/home/notomo/workspace/neovim/.deps/usr/share/lua/5.1/requireall/invalid/init.lua'
	no file './requireall/invalid.so'
	no file '/usr/local/lib/lua/5.1/requireall/invalid.so'
	no file '/home/notomo/workspace/neovim/.deps/usr/lib/lua/5.1/requireall/invalid.so'
	no file '/usr/local/lib/lua/5.1/loadall.so'
	no file './requireall.so'
	no file '/usr/local/lib/lua/5.1/requireall.so'
	no file '/home/notomo/workspace/neovim/.deps/usr/lib/lua/5.1/requireall.so'
	no file '/usr/local/lib/lua/5.1/loadall.so'

$ echo $?
1
```