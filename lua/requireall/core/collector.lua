local M = {}

function M.build_query()
  return vim.treesitter.query.parse(
    "lua",
    [[
(
  (function_call
    name: (_) @_require (#match? @_require "^require$")
    arguments: (arguments
      [
      (string
        content: (string_content) @name
      )
      (_)
      ] @name_node
    )
  ) @node
)
]]
  )
end

local tslib = require("requireall.lib.treesitter")

function M.collect(str, query)
  local root = tslib.get_first_tree_root(str, "lua")
  local matches = {}
  for _, match in query:iter_matches(root, str, 0, -1) do
    local captured = tslib.get_captures(match, query, {
      ["node"] = function(tbl, tsnode)
        tbl.node = tsnode
      end,
      ["name"] = function(tbl, tsnode)
        tbl.name = vim.treesitter.get_node_text(tsnode, str)
      end,
      ["name_node"] = function(tbl, tsnode)
        tbl.name_node = tsnode
      end,
    })
    table.insert(matches, captured)
  end
  return matches
end

return M
