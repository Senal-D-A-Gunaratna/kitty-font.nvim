# kitty-font.nvim

Temporarily switch Kitty's font while Neovim is running, then restore the
previous Kitty config on exit.

This plugin lets Neovim control Kitty's font family and size for the current
session, so you can switch fonts while editing and restore them automatically
when you leave.

## Experimental

This plugin is still experimental. The API and behavior may change as the
integration is refined.

## Setup

```lua
require("kitty-font").setup({
  font_family = "IosevkaTerm Nerd Font", -- default nil, uses kitty.conf
  font_size = 16, -- default nil, uses kitty.conf
  padding = "0 0", -- default nil, uses kitty.conf; accepts 1–4 values (CSS-style)
  padding_step = 2, -- default: 2
  restore_on_exit = true, -- default: true
})
```

`font_family` is used as the default family applied on startup and as the
initial selection basis for `FontPick`.

The plugin applies whichever of `font_family` and `font_size` you set when it
starts up, and restores the previous Kitty config on exit.

## Limitations

Kitty applies font changes to the current OS window, not to a single tab or
split. That means every tab and split inside that window changes together.

## Commands

`FontReset`
: Restore Kitty's active config by dropping the temporary overrides. Also restores window padding back to `kitty.conf`.

`FontPick`
: Open `vim.ui.select()` with fonts discovered asynchronously from `fc-list`.

`PaddingSet [top] [right] [bottom] [left]`
: Set Kitty `window_padding_width` to the given value(s). Accepts 0–4 space-separated numeric values, mirroring Kitty's own CSS-style padding syntax. Passing no arguments applies the configured `padding` value. Example: `:PaddingSet 0 0`.

`PaddingIncrease`
: Increase padding by `padding_step`.

`PaddingDecrease`
: Decrease padding by `padding_step`, clamped at 0.

## Health

Run `:checkhealth kitty-font` to verify that:

* `kitty` is available
* `fc-list` is available
* `KITTY_LISTEN_ON` is set when Neovim is launched outside Kitty
* `restore_on_exit` is enabled if you want the cleanup to run on exit
