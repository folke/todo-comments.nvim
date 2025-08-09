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

local function rgb_to_linear(c)
  c = c / 255
  return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

local function relative_luminance(color)
  return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
end

function M.hex2linear_srgb(hex)
  hex = hex:gsub("#", "")
  return {
    r = rgb_to_linear(tonumber("0x" .. hex:sub(1, 2))),
    g = rgb_to_linear(tonumber("0x" .. hex:sub(3, 4))),
    b = rgb_to_linear(tonumber("0x" .. hex:sub(5, 6))),
  }
end

function M.contrast_ratio(c1, c2)
  local lum1 = relative_luminance(c1)
  local lum2 = relative_luminance(c2)

  if lum1 < lum2 then
    lum1, lum2 = lum2, lum1
  end

  return (lum1 + 0.05) / (lum2 + 0.05)
end

function M.maximize_contrast(base, fg1, fg2)
  base = M.hex2linear_srgb(base)
  return M.contrast_ratio(base, M.hex2linear_srgb(fg1)) > M.contrast_ratio(base, M.hex2linear_srgb(fg2)) and fg1 or fg2
end

function M.warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "TodoComments" })
end

function M.error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "TodoComments" })
end

return M
