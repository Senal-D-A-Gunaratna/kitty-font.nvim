local kitty = require("kitty-font.kitty")

local M = {}

local created = false

---@param value any
---@return boolean
local function is_set(value)
	return value ~= nil and value ~= ""
end

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

			if kitty.is_fullscreen() and is_set(api.config.fullscreen_toggle_hook) then
				vim.system({ "sh", "-c", api.config.fullscreen_toggle_hook }, {}):wait()
			end

			api.restore({ silent = true })
		end,
	})
end

return M
