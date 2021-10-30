local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
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

source.complete = function(_, _, callback)
  local complete_items = {}
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local linenr = cursor_pos[1]
  local colnr = cursor_pos[0]
  local lines = vim.api.nvim_buf_get_lines(0, 0, linenr, false)
  lines[linenr] = lines[linenr]:sub(0, colnr)
  local script_parts = { "complete --do-complete '" }
  for _, line in ipairs(lines) do
    local escaped_line = line:gsub("\\", "\\\\"):gsub("'", "\\'")
    table.insert(script_parts, escaped_line)
  end
  local script = table.concat(script_parts, "\n") .. "'"
  local tmppath = os.tmpname()
  local tmpfile = io.open(tmppath, "w")
  tmpfile:write(script)
  tmpfile:close()
  local pipe = io.popen(string.format('fish "%s"', tmppath))
  local output = pipe:read("*a")
  pipe:close()
  os.remove(tmppath)
  for item in vim.gsplit(output, "\n") do
    local index = item:find("\t")
    if index ~= nil then
      local label = item:sub(0, index - 1)
      local detail = item:sub(index + 1, item:len())
      local kind = 12
      if string.find(detail, "^Executable") then
        kind = 3
      elseif string.find(label, "^-") then
        kind = 14
      end
      table.insert(complete_items, {
        label = label,
        kind = kind,
        detail = detail,
      })
    end
  end
  callback(complete_items)
end

return source
