local F = {}

function F.getCompletionItems(prefix)
  local complete_items = {}
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local linenr = cursor_pos[1]
  local colnr = cursor_pos[0]
  local lines = vim.api.nvim_buf_get_lines(0, 0, linenr, false)
  lines[linenr] = lines[linenr]:sub(0, colnr)
  local script_parts = {'complete --do-complete \''}
  for _, line in ipairs(lines) do
    local escaped_line = line:gsub("\\", "\\\\"):gsub("'", "\\'")
    table.insert(script_parts, escaped_line)
  end
  local script = table.concat(script_parts, '\n') .. "'"
  local tmppath = os.tmpname()
  local tmpfile = io.open(tmppath, "w")
  tmpfile:write(script)
  tmpfile:close()
  local pipe = io.popen(string.format('fish "%s"', tmppath))
  local output = pipe:read("*a")
  pipe:close()
  os.remove(tmppath)
  for completion in vim.gsplit(output, '\n') do
    local index = completion:find('\t')
    if index ~= nil then
      local word = completion:sub(0, index - 1)
      if vim.startswith(word, prefix) then
        table.insert(complete_items, {
            word = word,
            menu = completion:sub(index + 1, completion:len() - 1),
            kind = "Fish",
          })
      end
    end
  end
  return complete_items
end

F.complete_item = {
  item = F.getCompletionItems
}

return F
