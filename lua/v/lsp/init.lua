--[[ local status_ok, _ = pcall(require, "lspconfig") ]]
--[[ if not status_ok then ]]
--[[   return ]]
--[[ end ]]
--[[]]
--[[ require "v.lsp.mason" ]]
--[[ require("v.lsp.handlers").setup() ]]

local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = true,
})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()
lsp.configure('rust_analyzer', {
  settings = {
      ['rust-analyzer'] = {
          checkOnSave = {
              allFeatures = true,
              overrideCommand = {
                  'cargo', 'clippy', '--workspace', '--message-format=json',
                  '--all-targets', '--all-features'
              }
          },
          tools = {
              inlay_hints = {
                  auto = false
              }
          },
          diagnostics = {
              enable = true,
              experimental = {
                  enable = true,
              },
          },
      }
  }
})

local rust_lsp = lsp.build_options('rust_analyzer', {})

require("rust-tools").setup({ server = rust_lsp })

lsp.setup()
