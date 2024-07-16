local M = {}

local default_list_opts = {
  paths = function()
    local working_dir = vim.uv.cwd()
    return vim
      .iter(vim.fs.dir(working_dir, {
        depth = 100,
      }))
      :map(function(path, typ)
        if typ and typ ~= "file" then
          return
        end
        if not vim.endswith(path, ".lua") then
          return
        end

        local full_path = vim.fs.joinpath(working_dir, path)
        if full_path:find("/spec/") then
          return
        end

        return path
      end)
  end,
  sources = function()
    return vim.iter({})
  end,
}

function M.list_opts(raw_opts)
  local opts = vim.tbl_deep_extend("force", default_list_opts, raw_opts or {})
  return {
    paths = opts.paths(),
    sources = opts.sources(),
  }
end

local default_execute_opts = vim.deepcopy(default_list_opts)
default_execute_opts.module_filter = function(_)
  return true
end
default_execute_opts.exit = function(ok)
  if ok then
    vim.cmd.quitall()
    return
  end
  vim.cmd.cquit()
end

function M.execute_opts(raw_opts)
  local opts = vim.tbl_deep_extend("force", default_execute_opts, raw_opts or {})
  return {
    paths = opts.paths(),
    sources = opts.sources(),
    module_filter = opts.module_filter,
    exit = opts.exit,
  }
end

return M
