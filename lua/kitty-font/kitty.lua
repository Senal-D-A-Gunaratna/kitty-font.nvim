local M = {}

local KITTY_EXE = "kitty"

---@param message string
---@return nil, string
local function fail(message)
  return nil, message
end

---@param value any
---@return boolean
local function is_set(value)
  return value ~= nil and value ~= ""
end

---@param cmd string[]
---@return any?, string?
local function run(cmd)
  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    local stderr = result.stderr and vim.trim(result.stderr) or ""
    if stderr ~= "" then
      return nil, stderr
    end

    return nil, ("command failed with exit code %d"):format(result.code)
  end

  return result
end

---@return string?
local function target_address()
  local env_target = vim.env.KITTY_LISTEN_ON
  if env_target and env_target ~= "" then
    return env_target
  end

  return nil
end

---@param args string[]
---@return string[]
local function build_command(args)
  local cmd = { KITTY_EXE, "@" }
  local target = target_address()
  if target then
    vim.list_extend(cmd, { "--to", target })
  end

  vim.list_extend(cmd, args)
  return cmd
end

---@param config kitty_font.Config
---@param font string?
---@return string[]
local function build_load_args(config, font)
  local args = { "load-config" }
  local chosen = font or config.font_family

  if chosen and chosen ~= "" then
    vim.list_extend(args, { "-o", "font_family=" .. chosen })
  end

  if config.font_size ~= nil then
    vim.list_extend(args, { "-o", "font_size=" .. tostring(config.font_size) })
  end

  return args
end

---@return boolean
function M.available()
  return vim.fn.executable(KITTY_EXE) == 1
end

---@param args string[]?
---@return any?, string?
function M.load_config(args)
  local cmd, err = build_command(vim.list_extend({ "load-config" }, args or {}))
  if not cmd then
    return nil, err
  end

  return run(cmd)
end

---@param config kitty_font.Config
---@param font string?
---@return any?, string?
function M.apply(config, font)
  if (not is_set(font))
    and (not is_set(config.font_family))
    and config.font_size == nil
  then
    return fail("No font family provided")
  end

  local cmd, err = build_command(build_load_args(config, font))
  if not cmd then
    return nil, err
  end

  return run(cmd)
end

---@param config kitty_font.Config
---@param font string
---@return any?, string?
function M.switch(config, font)
  if not is_set(font) then
    return fail("No font family provided")
  end

  return M.apply(config, font)
end

---@return any?, string?
function M.reset()
  local cmd, err = build_command({
    "load-config",
    "--ignore-overrides",
  })
  if not cmd then
    return nil, err
  end

  local result, run_err = run(cmd)
  if not result then
    return nil, run_err
  end

  return result
end

return M
