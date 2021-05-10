--- @class Util
local M = {}

function M.get_hl(name)
  if not vim.fn.hlexists(name) then return nil end
  local hl = vim.api.nvim_get_hl_by_name(name, true)
  for _, key in pairs({ "foreground", "background", "special" }) do
    if hl[key] then hl[key] = string.format("#%06x", hl[key]) end
  end
  return hl
end

function M.hex2rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)),
         tonumber("0x" .. hex:sub(5, 6))
end

function M.rgb2hex(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end

function M.is_dark(hex)
  local r, g, b = M.hex2rgb(hex)
  local lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return lum <= 0.5
end

return M
