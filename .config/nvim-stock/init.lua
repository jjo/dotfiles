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

-- Completely disable LSP for terraform files to avoid errors
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.tf", "*.terraform"},
  callback = function()
    -- Disable LSP for this buffer
    vim.b.lsp_attach = false
    -- Stop any LSP clients that might have started
    vim.defer_fn(function()
      local clients = vim.lsp.get_active_clients({bufnr = 0})
      for _, client in pairs(clients) do
        if client.name:match("terraform") then
          vim.lsp.buf_detach_client(0, client.id)
        end
      end
    end, 100)
  end,
})

-- Override vim.schedule to catch and ignore the specific terraform LSP error
local original_schedule = vim.schedule
vim.schedule = function(fn)
  return original_schedule(function()
    local ok, err = pcall(fn)
    if not ok then
      local err_str = tostring(err)
      if not (err_str:match("expected a map, got 'slice'") or err_str:match("terraform")) then
        error(err)
      end
      -- Silently ignore terraform LSP errors
    end
  end)
end

