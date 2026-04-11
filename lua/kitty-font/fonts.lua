local M = {}

local FC_LIST_EXE = "fc-list"

---@alias kitty_font.FontListCallback fun(list: string[]?, err: string?)

---@param stdout string
---@return string[]
local function parse_stdout(stdout)
  local fonts = {}
  local seen = {}

  vim.iter(vim.split(stdout, "\n", { plain = true, trimempty = true })):each(function(line)
    for family in vim.gsplit(line, ",", { plain = true, trimempty = true }) do
      local name = vim.trim(family)
      if name ~= "" and not seen[name] then
        seen[name] = true
        fonts[#fonts + 1] = name
      end
    end
  end)

  table.sort(fonts)
  return fonts
end

---@param cmd string[]
---@param callback kitty_font.FontListCallback?
---@return string[]?, string?
local function run(cmd, callback)
  if callback then
    vim.system(cmd, { text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local stderr = result.stderr and vim.trim(result.stderr) or ""
          if stderr ~= "" then
            callback(nil, stderr)
            return
          end

          callback(nil, ("command failed with exit code %d"):format(result.code))
          return
        end

        callback(parse_stdout(result.stdout))
      end)
    end)

    return
  end

  local result = vim.system(cmd, { text = true }):wait()

  if result.code ~= 0 then
    local stderr = result.stderr and vim.trim(result.stderr) or ""
    if stderr ~= "" then
      return nil, stderr
    end

    return nil, ("command failed with exit code %d"):format(result.code)
  end

  return parse_stdout(result.stdout)
end

---@overload fun(): string[]?, string?
---@param callback kitty_font.FontListCallback?
function M.list(callback)
  local cmd = { FC_LIST_EXE, "-f", "%{family}\\n" }
  return run(cmd, callback)
end

return M
