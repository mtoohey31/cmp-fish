-- cspell:ignore jobstart jobstop chansend nvim

local source = {}
local fish_job_module = require("cmp_fish.fish_job")

---@class (exact) Options
---@field fish_path string|nil

source.new = function()
  local self = setmetatable({}, {
    __index = source,
  })
  self.fish_job = nil
  return self
end

source.reset = function(self)
  if self.fish_job ~= nil then
    self.fish_job:delete()
  end
end

source.is_available = function()
  return vim.bo.filetype == "fish"
end

source.get_debug_name = function()
  return "fish"
end

source.get_keyword_pattern = function(_)
  return [[.]]
end

--- Reverses a list.
---
---@tparam table list
---@tparam table
local reverse_list = function(list)
  local reversed_list = {}
  for i = #list, 1, -1 do
    table.insert(reversed_list, list[i])
  end
  return reversed_list
end

--- Validates options.
---
---@treturn Options
local validate_options = function(options)
  vim.validate({
    fish_path = { options.fish_path, { "string", "nil" } },
  })
  return options
end

source.complete = function(self, params, callback)
  local options = validate_options(params.option)
  if self.fish_job == nil then
    self.fish_job = fish_job_module:new(options.fish_path)
  elseif self.fish_job.fish_path ~= options.fish_path then
    -- A change of path shouldn’t really happen in most setups, because people usually hardcode it in their config, but
    -- in case that happens, reset the job.
    self.fish_job:delete()
    self.fish_job = fish_job_module:new(options.fish_path)
  end

  self.output_buffer = {}
  local relevant_lines = { params.context.cursor_before_line .. "\n" }
  local preceding_line = params.context.cursor.line - 1
  while preceding_line >= 0 do
    local line = vim.api.nvim_buf_get_lines(0, preceding_line, preceding_line + 1, true)[1]
    -- handles multi-line commands continued via a trailing backslash
    if line:match("\\%s*") ~= nil then
      table.insert(relevant_lines, line)
      preceding_line = preceding_line - 1
    else
      break
    end
  end
  self.fish_job:send(reverse_list(relevant_lines), callback)
end

return source
