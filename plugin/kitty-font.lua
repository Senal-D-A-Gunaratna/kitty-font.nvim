if vim.g.loaded_kitty_font == 1 then
  return
end

vim.g.loaded_kitty_font = 1

require("kitty-font").setup()
