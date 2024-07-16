local M = {}

--- @class RequireallListOption
--- @field paths (fun():string[])? find require() call from these lua file path (default: find non-test lua files under working directory recursively)
--- @field sources (fun():string[])? find require() call from these lua source code

--- @class RequireallList
--- @field path string? file path (not nil if specified by option)
--- @field source string lua source code
--- @field matches RequireallMatch[]

--- @class RequireallMatch
--- @field node TSNode require() call node
--- @field name_node TSNode require() argument node
--- @field name string? require() argument string (not nil if it is static string)

--- List require() call in source.
--- @param opts RequireallListOption?
--- @return RequireallList
function M.list(opts)
  return require("requireall.command").list(opts)
end

--- @class RequireallExecuteOption
--- @field paths (fun():string[])? find require() call from these lua file path
--- @field sources (fun():string[])? find require() call from these lua source code
--- @field module_filter (fun(module_path:string):boolean)? call require(module_path) if returns true
--- @field exit (fun(has_error:boolean))? function called on finished (default: exit nvim with status code)

--- Execute require() in source and its path.
--- @param opts RequireallExecuteOption?
function M.execute(opts)
  return require("requireall.command").execute(opts)
end

return M
