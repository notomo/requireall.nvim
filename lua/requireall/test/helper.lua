local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

helper.root = helper.find_plugin_root(plugin_name)
vim.opt.packpath:prepend(vim.fs.joinpath(helper.root, "spec/.shared/packages"))
require("assertlib").register(require("vusted.assert").register)

local notify = vim.notify
function helper.before_each()
  helper.test_data = require("requireall.vendor.misclib.test.data_dir").setup(helper.root)
  vim.notify = notify
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
  helper.test_data:teardown()
end

return helper
