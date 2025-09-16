-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- LazyVim의 커스텀 n, N 매핑을 삭제하여 Neovim 기본 동작으로 되돌립니다.
vim.keymap.del("n", "n")
vim.keymap.del("n", "N")
