-- Load shared vim settings first
vim.cmd('source ' .. os.getenv("HOME") .. '/.config/nvim/init_vim.vim')

-- =============================================================================
-- LAZY.NVIM BOOTSTRAP
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- PLUGINS (nvim-specific, AI via OpenRouter/Claude)
-- =============================================================================
require("lazy").setup({
  -- Dependencies
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Avante.nvim - Cursor-like AI assistant
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "stevearc/dressing.nvim",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-opus-4-20250514",
          api_key_name = "ANTHROPIC_API_KEY",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 4096,
          },
        },
      },
      behaviour = {
        auto_suggestions = false,  -- Using Codeium/Copilot instead
        auto_set_keymaps = false,  -- Using explicit keymaps below
      },
    },
  },

  -- Dressing.nvim for better UI
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {},
  },
}, {
  -- Lazy.nvim options
  install = {
    colorscheme = { "gruvbox" },
  },
  checker = {
    enabled = false,  -- Don't auto-check for updates
  },
  performance = {
    reset_packpath = false,  -- Don't reset packpath, keep Vundle plugins
    rtp = {
      reset = false,  -- Don't reset runtimepath, keep .vimrc plugins working
    },
  },
})

-- =============================================================================
-- KEYMAPS FOR AI
-- =============================================================================
-- Avante keymaps (explicit to avoid 'a' append conflict)
vim.keymap.set('n', '<leader>aa', '<cmd>AvanteAsk<cr>', { desc = "Avante Ask" })
vim.keymap.set('v', '<leader>aa', '<cmd>AvanteAsk<cr>', { desc = "Avante Ask" })
vim.keymap.set('n', '<leader>ae', '<cmd>AvanteEdit<cr>', { desc = "Avante Edit" })
vim.keymap.set('v', '<leader>ae', '<cmd>AvanteEdit<cr>', { desc = "Avante Edit" })
vim.keymap.set('n', '<leader>ac', '<cmd>AvanteChat<cr>', { desc = "Avante Chat" })
vim.keymap.set('n', '<leader>ar', '<cmd>AvanteRefresh<cr>', { desc = "Avante Refresh" })
vim.keymap.set('n', '<leader>at', '<cmd>AvanteToggle<cr>', { desc = "Avante Toggle" })

-- =============================================================================
-- TERRAFORM LSP WORKAROUND (kept from original)
-- =============================================================================
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.tf", "*.terraform"},
  callback = function()
    vim.b.lsp_attach = false
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

-- Override vim.schedule to catch terraform LSP errors
local original_schedule = vim.schedule
vim.schedule = function(fn)
  return original_schedule(function()
    local ok, err = pcall(fn)
    if not ok then
      local err_str = tostring(err)
      if not (err_str:match("expected a map, got 'slice'") or err_str:match("terraform")) then
        error(err)
      end
    end
  end)
end
