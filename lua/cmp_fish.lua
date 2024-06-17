-- cspell:ignore jobstart jobstop chansend nvim

local source = {}
local fish_job_module = require("cmp_fish.fish_job")

source.new = function()
  local self = setmetatable({}, {
    __index = source,
  })
  self.fish_job = fish_job_module:new()
  return self
end

source.reset = function(self)
  self.fish_job:delete()
  self.fish_job = fish_job_module:new()
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

source.complete = function(self, params, callback)
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
