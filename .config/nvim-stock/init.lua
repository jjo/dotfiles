# From: https://github.com/folke/lazy.nvim
if false then
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
      })
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup(plugins, opts)
end

--require('plugins')
--use ({
--    "Bryley/neoai.nvim",
--    require = { "MunifTanjim/nui.nvim" },
--})
vim.cmd('source ' .. os.getenv("HOME") .. '/.config/nvim/init_vim.vim')

