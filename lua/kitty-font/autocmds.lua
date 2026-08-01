local M = {}

local created = false

---@param api kitty_font.API
function M.setup(api)
  if created then
    return
  end

  created = true

  local group = vim.api.nvim_create_augroup("KittyFont", { clear = true })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    desc = "Restore Kitty font and padding settings",
    callback = function()
      if not api.config.restore_on_exit then
        return
      end

      api.restore({ silent = true })
    end,
  })
end

return M
