--- A Fish complete job that runs in the background.
---
--- Warning: the current implementation is fully asynchronous and race conditions are possible. In practice, this hasn’t
--- been an issue so far, but it’s something to keep in mind.
--
-- @module cmp_fish.fish_job
-- @alias FishJob

local FishJob = {}

--- Starts a new Fish job.
---
---@tparam string|nil fish_path
function FishJob:new(fish_path)
  fish_path = fish_path or "fish"
  local fish_job = {
    job_id = nil,
    output_buffer = {},
    fish_path = fish_path,
    callback = nil,
  }
  setmetatable(fish_job, self)
  self.__index = self

  fish_job.job_id = vim.fn.jobstart({ fish_path, "-ic", 'while read val -P ""; complete -C "$val"; end' }, {
    shell = fish_path,
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line == "" and fish_job.callback ~= nil then
          local complete_items = {}
          for _, item in ipairs(fish_job.output_buffer) do
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
          fish_job.callback(complete_items)
          fish_job.callback = nil
          fish_job.output_buffer = {}
        else
          table.insert(fish_job.output_buffer, line)
        end
      end
    end,
  })

  return fish_job
end

--- Stops and destroys the Fish job.
function FishJob:delete()
  if self.job_id == nil then
    -- There’s nothing to delete.
    return
  end
  vim.fn.jobstop(self.job_id)
  self.job_id = nil
  self.output_buffer = {}
  self.callback = nil
end

--- Send lines to complete to the Fish job.
---
---@tparam table lines A list of lines to complete.
---@tparam function callback The callback to call with completions.
function FishJob:send(lines, callback)
  self.output_buffer = {}
  self.callback = callback
  for _, line in ipairs(lines) do
    vim.fn.chansend(self.job_id, line)
  end
end

return FishJob
