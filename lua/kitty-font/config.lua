---@class kitty_font.Config
---@field font_family string?
---@field font_size number?
---@field padding string|number|nil
---@field padding_step number
---@field restore_on_exit boolean

---@class kitty_font.ConfigOpts
---@field font_family string?
---@field font_size number?
---@field padding string|number|nil
---@field padding_step number?
---@field restore_on_exit boolean?

local M = {}

---@type kitty_font.Config
M.defaults = {
  font_family = nil,
  font_size = nil,
  padding = nil,
  padding_step = 2,
  restore_on_exit = true,
}

---@param opts kitty_font.ConfigOpts?
---@return kitty_font.Config
function M.normalize(opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
