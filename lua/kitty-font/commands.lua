local M = {}

local created = false

---@param api kitty_font.API
function M.setup(api)
  if created then
    return
  end

  created = true

  vim.api.nvim_create_user_command("FontReset", function()
    api.reset()
  end, {
    desc = "Reset Kitty font",
    force = true,
  })

  vim.api.nvim_create_user_command("FontPick", function()
    api.pick()
  end, {
    desc = "Pick font interactively",
    force = true,
  })
end

return M
