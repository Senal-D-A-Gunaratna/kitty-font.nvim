local config = require("kitty-font.config")
local kitty = require("kitty-font.kitty")
local fonts = require("kitty-font.fonts")
local commands = require("kitty-font.commands")
local autocmds = require("kitty-font.autocmds")

---@class kitty_font.ApplyOpts
---@field silent boolean?

---@class kitty_font.API
---@field config kitty_font.Config
---@field setup fun(opts?: kitty_font.ConfigOpts): kitty_font.Config
---@field apply fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field reset fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field get_fonts fun(): string[]
---@field pick fun(opts?: kitty_font.ApplyOpts)
---@field health fun()

---@type kitty_font.API
local M = {}

M.config = config.normalize()

---@param message string
---@param level integer?
local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO)
end

---@param value any
---@return boolean
local function is_set(value)
  return value ~= nil and value ~= ""
end

---@param opts kitty_font.ConfigOpts?
---@return kitty_font.Config
function M.setup(opts)
  M.config = config.normalize(vim.tbl_deep_extend("force", {}, M.config, opts or {}))

  commands.setup(M)
  autocmds.setup(M)

  if is_set(M.config.font_family) or M.config.font_size ~= nil then
    M.apply({ silent = true })
  end

  return M.config
end

---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.apply(opts)
  opts = opts or {}

  local result, err = kitty.apply(M.config)
  if not result then
    if not opts.silent then
      notify("FontApply: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  if not opts.silent then
    notify("Applied Kitty font settings")
  end

  return true
end

---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.reset(opts)
  opts = opts or {}

  local result, err = kitty.reset()
  if not result then
    if not opts.silent then
      notify("FontReset: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  if not opts.silent then
    notify("Font reset to default")
  end

  return true
end

---@return string[]
function M.get_fonts()
  local list, err = fonts.list()
  if not list then
    notify("FontPick: " .. err, vim.log.levels.ERROR)
    return {}
  end

  return list
end

---@param opts kitty_font.ApplyOpts?
function M.pick(opts)
  opts = opts or {}

  fonts.list(function(list, err)
    if not list or #list == 0 then
      notify("FontPick: " .. (err or "No fonts found"), vim.log.levels.ERROR)
      return
    end

    vim.ui.select(list, {
      prompt = "Select Kitty font: ",
    }, function(choice)
      if choice then
        local result, switch_err = kitty.switch(M.config, choice)
        if not result then
          notify("FontPick: " .. switch_err, vim.log.levels.ERROR)
          return
        end

        if not opts.silent then
          notify("Switched font to: " .. choice)
        end
      end
    end)
  end)
end

---@return table
function M.health()
  return require("kitty-font.health")
end

return M
