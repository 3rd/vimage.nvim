local u = require("vimage.util")
local log = u.log

local FIFO_PATH = u.os.env("FIFO_UEBERZUG")
local SCALER = {
  CROP = "crop",
  DISTORT = "distort",
  FIT_CONTAIN = "fit_contain",
  CONTAIN = "contain",
  FORCED_COVER = "forced_cover",
  COVER = "cover"
}

local rendered = {}

-- rendered helpers
local rendered_find_index = function (id)
  local index = nil
  for i, v in ipairs(rendered) do
    if v == id then
      index = i
    end
  end
  return index
end
local rendered_add = function (id)
  table.insert(rendered, id)
end
local rendered_remove = function (id)
  local index = rendered_find_index(id)
  if index ~= nil then
    table.remove(rendered, index)
  end
end

-- module
local ueberzug = {}

-- fifo
ueberzug.request = function(payload)
  local path = FIFO_PATH
  local fifo = io.open(path, "w")
  if fifo == nil then
    error("Cannot perform request, no fifo handle.")
  end
  local encoded_payload = u.json.encode(payload)
  -- log(encoded_payload)
  fifo:write(encoded_payload .. "\r\n")
  fifo:close()
end

-- draw
ueberzug.draw = function(id, path, x, y, w, h)
  local resolved_path = u.fs.resolve(path)
  if resolved_path == nil then
    error("Cannot find image at " .. path)
    return
  end
  local payload = {
    action = "add",
    identifier = id,
    path = resolved_path,
    x = x,
    y = y,
    width = w,
    height = h,
    scaler = SCALER.FIT_CONTAIN
  }
  ueberzug.request(payload)
  rendered_add(id)
end

-- clear
ueberzug.clear = function(id)
  local payload = {
    action = 'remove',
    identifier = id
  }
  ueberzug.request(payload)
  rendered_remove(id)
end

-- clear all
ueberzug.clear_all = function()
  for _, id in ipairs(rendered) do
    ueberzug.clear(id)
  end
end

-- expose rendered images
ueberzug.get_rendered_images = function()
  return rendered
end

return ueberzug
