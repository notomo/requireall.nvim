local M = {}

function M.get_first_tree_root(str, language)
  local parser = vim.treesitter.get_string_parser(str, language)
  local trees = parser:parse()
  return trees[1]:root()
end

function M.get_captures(match, query, handlers)
  local captures = {}
  for id, nodes in pairs(match) do
    for _, node in ipairs(nodes) do
      local captured = query.captures[id]
      local f = handlers[captured]
      if f then
        f(captures, node)
      end
    end
  end
  return captures
end

return M
