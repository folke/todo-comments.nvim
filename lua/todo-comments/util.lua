--- @class Util
local M = {}

function M.get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
  if not ok then
    return
  end
  for _, key in pairs({ "foreground", "background", "special" }) do
    if hl[key] then
      hl[key] = string.format("#%06x", hl[key])
    end
  end
  return hl
end

function M.hex2rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

function M.rgb2hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

function M.is_dark(hex)
  local r, g, b = M.hex2rgb(hex)
  local lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return lum <= 0.5
end

function M.color_distance(r1, g1, b1, r2, g2, b2)
  return math.sqrt((r1 - r2) ^ 2 + (g1 - g2) ^ 2 + (b1 - b2) ^ 2)
end

function M.select_fg(base, fg1, fg2)
  local r, g, b = M.hex2rgb(base)
  return M.color_distance(r, g, b, M.hex2rgb(fg1)) > M.color_distance(r, g, b, M.hex2rgb(fg2)) and fg1 or fg2
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "TodoComments" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "TodoComments" })
end

return M
