-- cspell:ignore jobstart jobstop chansend nvim

local source = {}

local create_job = function(self)
  return vim.fn.jobstart({ "fish", "-ic", 'while read val -P ""; complete -C "$val"; end' }, {
    shell = "fish",
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line == "" and self.callback ~= nil then
          local complete_items = {}
          for _, item in ipairs(self.output_buffer) do
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
          self.callback(complete_items)
          self.callback = nil
          self.output_buffer = {}
        else
          table.insert(self.output_buffer, line)
        end
      end
    end,
  })
end

source.new = function()
  local self = setmetatable({}, {
    __index = source,
  })
  self.output_buffer = {}
  self.fish_job = create_job(self)
  return self
end

source.reset = function(self)
  vim.fn.jobstop(self.fish_job)
  self.output_buffer = {}
  self.fish_job = create_job(self)
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

source.complete = function(self, params, callback)
  self.output_buffer = {}
  local relevant_lines = { params.context.cursor_before_line .. "\n" }
  local preceding_line = params.context.cursor.line - 1
  while preceding_line >= 0 do
    local line = vim.api.nvim_buf_get_lines(0, preceding_line, preceding_line + 1, true)[1]
    if line:match("\\%s*") ~= nil then
      print("matched")
      table.insert(relevant_lines, line)
      preceding_line = preceding_line - 1
    else
      break
    end
  end
  for i = #relevant_lines, 1, -1 do
    vim.fn.chansend(self.fish_job, relevant_lines[i])
  end
  self.callback = callback
end

return source
