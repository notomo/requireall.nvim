local M = {}

local list = function(paths, sources)
  local query = require("requireall.core.collector").build_query()

  local from_paths = vim.iter(paths):map(function(path)
    local absolute_path = vim.fn.fnamemodify(path, ":p")
    local source = require("requireall.lib.file").read_all(absolute_path)
    if type(source) == "table" then
      local err = source
      error("[requireall] " .. err.message)
    end

    local matches = require("requireall.core.collector").collect(source, query)

    return {
      path = absolute_path,
      source = source,
      matches = matches,
    }
  end)

  local from_sources = vim.iter(sources):map(function(source)
    local matches = require("requireall.core.collector").collect(source, query)
    return {
      path = nil,
      source = source,
      matches = matches,
    }
  end)

  return function()
    local from_path = from_paths:next()
    if from_path then
      return from_path
    end

    local from_source = from_sources:next()
    if from_source then
      return from_source
    end

    return nil
  end
end

function M.list(raw_opts)
  local opts = require("requireall.option").list_opts(raw_opts)
  return vim.iter(list(opts.paths, opts.sources)):totable()
end

function M.execute(raw_opts)
  local opts = require("requireall.option").execute_opts(raw_opts)

  local already = {}
  local errors = {}
  local call_require = function(name)
    if already[name] then
      return
    end
    already[name] = true

    vim.notify(("[requireall] calling require(): %s"):format(name), vim.log.levels.DEBUG)

    local ok, result = pcall(require, name)
    if not ok then
      vim.notify(result, vim.log.levels.WARN)
      table.insert(errors, {
        name = name,
        message = result,
      })
    end
  end

  vim.iter(list(opts.paths, opts.sources)):each(function(item)
    if item.path then
      vim.notify(("[requireall] path: %s"):format(vim.fn.fnamemodify(item.path, ":.")), vim.log.levels.DEBUG)

      local name = require("requireall.vendor.misclib.module.path").detect(item.path)
      if name ~= "" and opts.module_filter(name) then
        call_require(name)
      end
    else
      vim.notify(
        ("[requireall] source: %s ..."):format(item.source:sub(0, item.source:find("\n") - 1)),
        vim.log.levels.DEBUG
      )
    end

    vim
      .iter(item.matches)
      :map(function(match)
        return match.name
      end)
      :filter(opts.module_filter)
      :each(function(name)
        call_require(name)
      end)
  end)

  local ok = #errors == 0
  if not ok then
    vim.notify(
      ("[requireall] errors (count: %d)\n%s"):format(
        #errors,
        vim
          .iter(errors)
          :map(function(err)
            return ("require(%q): %s"):format(err.name, err.message)
          end)
          :join("\n")
      ),
      vim.log.levels.WARN
    )
  end

  vim.notify("", vim.log.levels.INFO)

  opts.exit(ok)
end

return M
