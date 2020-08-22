local json = require "vimage.json"
local api = vim.api
local fn = vim.fn

local util = {}

-- vendor
util.json = json

-- log
util.log = function (item)
  print(vim.inspect(item))
end

-- string
util.string = {}
util.string.get_display_width = function(str)
  return api.nvim_strwidth(str)
end
util.string.count = function(str, pattern)
  return select(2, string.gsub(str, pattern, ""))
end

-- nanoid - https://gist.github.com/jrus/3197011
util.nanoid = function()
  local template ='xxxxxxxx'
  return string.gsub(template, '[x]', function (c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- os
util.os = {}
util.os.env = function(key)
  return vim.fn.getenv(key)
end

-- fs
util.fs = {}
util.fs.exists = function(path)
  local result, err, code = os.rename(path, path)
  if not result then
    if code == 13 then
      return true
    end
  end
  return result, err
end
util.fs.resolve = function(path)
  local absolute = path
  if string.sub(absolute, 1, 1) ~= "/" then
    local dir = fn.expand("%:p:h")
    absolute = dir .. "/" .. path
  end
  if util.fs.exists(absolute) then
    return absolute
  end
  return nil
end

-- buffers
util.buffer = {}
util.buffer.get_current = function()
  return api.nvim_get_current_buf()
end
util.buffer.get_filetype = function()
  return api.nvim_get_option("filetype")
end
util.buffer.get_lines = function(buffer)
  return api.nvim_buf_get_lines(buffer, 0, -1, false)
end
util.buffer.get_text = function(buffer)
  local lines = util.buffer.get_lines(buffer)
  return table.concat(lines, "\n")
end

-- windows
util.window = {}
util.window.get_current = function()
  return api.nvim_get_current_win()
end
util.window.get_number = function(win)
  return api.nvim_win_get_number(win)
end
util.window.get_position = function(win)
  return unpack(api.nvim_win_get_position(win))
end
util.window.get_width = function(win)
  return api.nvim_win_get_width(win)
end
util.window.get_height = function(win)
  return api.nvim_win_get_height(win)
end
util.window.get_text_width = function(win)
  local width = util.window.get_width(win)
  local number_width = api.nvim_win_get_option(win, "numberwidth")
  local fold_column = api.nvim_win_get_option(win, "foldcolumn")
  width = width - number_width - fold_column
  return width
end
util.window.get_number_width = function(win)
  return api.nvim_win_get_option(win, "numberwidth")
end
util.window.get_buffer = function(win)
  return api.nvim_win_get_buf(win)
end
util.window.focus = function(nr)
  api.nvim_command(nr .. 'wincmd w')
end
util.window.close = function(win)
  api.nvim_win_close(win)
end
util.window.get_top_line_number = function()
  return vim.fn.line("w0")
end
util.window.get_bottom_line_number = function()
  return vim.fn.line("w$")
end


-- autocmd
util.au = {}

-- // https://teukka.tech/luanvim.html
util.au.register_group = function (definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup ' .. group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command('augroup END')
  end
end

return util
