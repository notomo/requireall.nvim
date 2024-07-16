local M = {}

function M.detect(file_path)
  file_path = vim.fs.normalize(file_path)

  local index = file_path:find("/lua/")
  if not index then
    return ""
  end

  local module_path = file_path:sub(index + #"/lua/"):gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
  return module_path
end

return M
