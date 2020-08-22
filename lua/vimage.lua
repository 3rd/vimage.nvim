local u = require("vimage.util")
local a = require("vimage.async")
local ueberzug = require("vimage.ueberzug")

local log = u.log

local plugin = {}

local window_images = {}
local window_top = {}

local get_line_heights = function()
  return vim.fn['vimage#compute_line_heights']()
end

-- TODO: hide all images while a floating window is open
-- if vim.api.nvim_win_get_config(win).relative ~= "" then
--   plugin.clear()
--   return
-- end
-- TODO: process images / create ueberzug alternative for cropped contain scaling

plugin.draw = a.sync(function()
  local images = {}
  -- get window info
  local win = u.window.get_current()
  local buff = u.window.get_buffer(win)
  local win_width = u.window.get_width(win)
  local win_y, win_x  = u.window.get_position(win)
  -- temporary: bail on floating windows
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return
  end
  -- get lines and line heights
  local lines = u.buffer.get_lines(buff)
  local line_heights = get_line_heights()
  local top = u.window.get_top_line_number()
  -- store top for cursor events
  window_top[win] = top
  -- calculate window lines to top line
  local window_lines_to_top_line = 0
  for i=1,top-1 do
    window_lines_to_top_line = window_lines_to_top_line + line_heights[i]
  end
  -- loop over each line and collect images, index them by line number and window line number
  local window_lines = 0
  for i, line in ipairs(lines) do
    local line_height = line_heights[i]
    local image = string.match(line, "!%[(.-)]")
    if image then
      -- local id = u.nanoid()
      local id = win .. ":" .. i .. ":" .. image
      local window_line = window_lines + line_height - 1
      local visual_line = window_line - window_lines_to_top_line
      table.insert(images, {
        id = id,
        line = i,
        window_line = window_line,
        visual_line = visual_line,
        path = image
      })
    end
    window_lines = window_lines + line_height
  end
  -- loop over all images and compute their height
  for _, image in ipairs(images) do
    local height = 1
    for i=image.line+1,#lines do
      local line = lines[i]
      if string.len(line:gsub("%s+", "")) == 0 then
        height = height + 1
      else
          break
      end
    end
    image.height = height - 1
  end
  -- render images
  local presence_map = {}
  for _, image in ipairs(images) do
    if image.height > 1 then
      local x = win_x + 0 + u.window.get_number_width(win) + 2
      local y = win_y + image.visual_line + 1
      local width = win_width
      local height = image.height - 1
      ueberzug.draw(image.id, image.path, x, y, width, height)
      presence_map[image.id] = true
    end
  end
  -- clear old images that are no longer present
  if window_images[win] ~= nil then
    for _, image in ipairs(window_images[win]) do
      if not presence_map[image.id] then
        ueberzug.clear(image.id)
      end
    end
  end

  window_images[win] = images
end)

plugin.clear = a.sync(function()
  -- get window info
  local win = u.window.get_current()
  -- clear previous images
  if window_images[win] then
    for _, image in ipairs(window_images[win]) do
      ueberzug.clear(image.id)
    end
    window_images[win] = {}
  end
end)

plugin.handle_cursor_moved = a.sync(function()
  local win = u.window.get_current()
  local top = u.window.get_top_line_number(win)
  if window_top[win] == top then
    return
  end
  plugin.draw()
end)

return plugin
