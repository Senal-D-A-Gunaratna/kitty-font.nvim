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

  vim.api.nvim_create_user_command("PaddingSet", function(cmdopts)
    local value = #cmdopts.fargs > 0 and table.concat(cmdopts.fargs, " ") or nil
    api.set_padding(value)
  end, {
    nargs = "*",
    desc = "Set Kitty window padding",
    force = true,
  })

  vim.api.nvim_create_user_command("PaddingReset", function()
    api.reset_padding()
  end, {
    desc = "Reset Kitty window padding to default",
    force = true,
  })

  vim.api.nvim_create_user_command("KittyReset", function()
    api.restore()
  end, {
    desc = "Reset Kitty font and padding",
    force = true,
  })

  vim.api.nvim_create_user_command("KittyApply", function()
    api.apply_all()
  end, {
    desc = "Apply configured Kitty font and padding settings",
    force = true,
  })
end

return M
