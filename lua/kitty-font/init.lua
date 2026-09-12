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
---@field apply_all fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field reset fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field restore fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field toggle_fullscreen fun(opts?: kitty_font.ApplyOpts): boolean?, string?
---@field get_fonts fun(): string[]
---@field pick fun(opts?: kitty_font.ApplyOpts)
---@field set_padding fun(padding?: string|number, opts?: kitty_font.ApplyOpts): boolean?, string?
---@field reset_padding fun(opts?: kitty_font.ApplyOpts): boolean?, string?
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

  if is_set(M.config.padding) then
    M.set_padding(nil, { silent = true })
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
function M.apply_all(opts)
  opts = opts or {}

  local font_result, font_err
  if is_set(M.config.font_family) or M.config.font_size ~= nil then
    font_result, font_err = M.apply({ silent = true })
    if not font_result then
      if not opts.silent then
        notify("FontApply: " .. font_err, vim.log.levels.ERROR)
      end

      return nil, font_err
    end
  end

  local padding_result, padding_err
  if is_set(M.config.padding) then
    padding_result, padding_err = M.set_padding(nil, { silent = true })
    if not padding_result then
      if not opts.silent then
        notify("PaddingSet: " .. padding_err, vim.log.levels.ERROR)
      end

      return nil, padding_err
    end
  end

  if not opts.silent then
    notify("Applied Kitty font and padding settings")
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

---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.restore(opts)
  opts = opts or {}

  local result, err = kitty.reset()
  if not result then
    if not opts.silent then
      notify("FontReset: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  local padding_result, padding_err = kitty.reset_padding()
  if not padding_result then
    if not opts.silent then
      notify("PaddingReset: " .. padding_err, vim.log.levels.ERROR)
    end

    return nil, padding_err
  end

  if not opts.silent then
    notify("Restored Kitty font and padding settings")
  end

  return true
end

---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.toggle_fullscreen(opts)
  opts = opts or {}

  local result, err = kitty.toggle_fullscreen()
  if not result then
    if not opts.silent then
      notify("FullscreenToggle: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  if is_set(M.config.fullscreen_toggle_hook) then
    vim.system({ "sh", "-c", M.config.fullscreen_toggle_hook }, {}, function(hook_result)
      if hook_result.code ~= 0 and not opts.silent then
        vim.schedule(function()
          notify("FullscreenToggleHook: exited " .. hook_result.code, vim.log.levels.WARN)
        end)
      end
    end)
  end

  if not opts.silent then
    notify("Toggled Kitty fullscreen")
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

---@param padding string|number|nil
---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.set_padding(padding, opts)
  opts = opts or {}

  local value = padding or M.config.padding
  local result, err = kitty.apply_padding(M.config, value)
  if not result then
    if not opts.silent then
      notify("PaddingSet: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  M.config.padding = value

  if not opts.silent then
    notify("Set Kitty padding to: " .. tostring(value))
  end

  return true
end

---@param opts kitty_font.ApplyOpts?
---@return boolean?, string?
function M.reset_padding(opts)
  opts = opts or {}

  local result, err = kitty.reset_padding()
  if not result then
    if not opts.silent then
      notify("PaddingReset: " .. err, vim.log.levels.ERROR)
    end

    return nil, err
  end

  if not opts.silent then
    notify("Padding reset to default")
  end

  return true
end

---@return table
function M.health()
  return require("kitty-font.health")
end

return M
