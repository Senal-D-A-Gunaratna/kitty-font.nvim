local M = {}

function M.check()
  vim.health.start("kitty-font")

  if vim.fn.executable("kitty") == 1 then
    vim.health.ok("kitty executable found")
  else
    vim.health.error("kitty executable not found")
  end

  if vim.fn.executable("fc-list") == 1 then
    vim.health.ok("fc-list executable found")
  else
    vim.health.error("fc-list executable not found")
  end

  if vim.env.KITTY_LISTEN_ON and vim.env.KITTY_LISTEN_ON ~= "" then
    vim.health.ok("KITTY_LISTEN_ON is set")
  else
    vim.health.info("Run Neovim inside Kitty or export KITTY_LISTEN_ON")
  end
end

return M
