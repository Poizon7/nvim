return {
  'VonHeikemen/lsp-zero.nvim',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason.nvim'},           -- Optional
    {'williamboman/mason-lspconfig.nvim'}, -- Optional
    {'simrat39/rust-tools.nvim'},
    {'https://git.sr.ht/~whynothugo/lsp_lines.nvim'},

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},         -- Required
    {'hrsh7th/cmp-nvim-lsp'},     -- Required
    {'hrsh7th/cmp-buffer'},       -- Optional
    {'hrsh7th/cmp-path'},         -- Optional
    {'saadparwaiz1/cmp_luasnip'}, -- Optional
    {'hrsh7th/cmp-nvim-lua'},     -- Optional

    -- Snippets
    {'L3MON4D3/LuaSnip'},             -- Required
    {'rafamadriz/friendly-snippets'}, -- Optional
  },
  config = function()
     local lsp = require('lsp-zero').preset({
       name = 'minimal',
       set_lsp_keymaps = true,
       manage_nvim_cmp = true,
       suggest_lsp_servers = true,
     })

     lsp.nvim_workspace()
     lsp.skip_server_setup({ 'rust_analyzer' })

     lsp.ensure_installed({
       "lua_ls",
       "rust_analyzer",
       "clangd",
       "pylsp"
     })

     lsp.configure('lua_ls', {
        settings = {
           Lua = {
               diagnostics = {
                   globals = { "vim" },
               },
               workspace = {
                   library = {
                       [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                       [vim.fn.stdpath("config") .. "/lua"] = true,
                   },
               },
           },
       }
     })

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

     local function lsp_highlight_document(client)
        -- Set autocommands conditional on server_capabilities
        if client.server_capabilities.documentHighlight then
          vim.api.nvim_exec(
            [[
            augroup lsp_document_highlight
              autocmd! * <buffer>
              autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
              autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
          ]],
            false
          )
        end
      end

      local function lsp_keymaps(bufnr)
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
        vim.api.nvim_buf_set_keymap(
          bufnr,
          "n",
          "gl",
          '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>',
          opts
        )
        vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>r", "<cmd> ClangdSwitchSourceHeader <cr>", opts)
        vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
      end

      lsp.on_attach = function(client, bufnr)
        if client.name == "tsserver" then
          client.server_capabilities.documentFormattingProvider = false
        end
        lsp_keymaps(bufnr)
        lsp_highlight_document(client)
      end

     local cmp_status_ok, cmp = pcall(require, "cmp")
     if not cmp_status_ok then
       return
     end

     local snip_status_ok, luasnip = pcall(require, "luasnip")
     if not snip_status_ok then
       return
     end

     require("luasnip/loaders/from_vscode").lazy_load()

     local check_backspace = function()
       local col = vim.fn.col "." - 1
       return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
     end

     --   פּ ﯟ   some other good icons
     local kind_icons = {
       Text = "",
       Method = "m",
       Function = "",
       Constructor = "",
       Field = "",
       Variable = "",
       Class = "",
       Interface = "",
       Module = "",
       Property = "",
       Unit = "",
       Value = "",
       Enum = "",
       Keyword = "",
       Snippet = "",
       Color = "",
       File = "",
       Reference = "",
       Folder = "",
       EnumMember = "",
       Constant = "",
       Struct = "",
       Event = "",
       Operator = "",
       TypeParameter = "",
     }
     -- find more here: https://www.nerdfonts.com/cheat-sheet

     lsp.setup_nvim_cmp({
       snippet = {
         expand = function(args)
           luasnip.lsp_expand(args.body) -- For `luasnip` users.
         end,
       },
       mapping = {
         ["<C-k>"] = cmp.mapping.select_prev_item(),
             ["<C-j>"] = cmp.mapping.select_next_item(),
         ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
         ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
         ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
         ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
         ["<C-e>"] = cmp.mapping {
           i = cmp.mapping.abort(),
           c = cmp.mapping.close(),
         },
         -- Accept currently selected item. If none selected, `select` first item.
         -- Set `select` to `false` to only confirm explicitly selected items.
         ["<CR>"] = cmp.mapping.confirm { select = true },
         ["<Tab>"] = cmp.mapping(function(fallback)
           if cmp.visible() then
             cmp.select_next_item()
           elseif luasnip.expandable() then
             luasnip.expand()
           elseif luasnip.expand_or_jumpable() then
             luasnip.expand_or_jump()
           elseif check_backspace() then
             fallback()
           else
             fallback()
           end
         end, {
           "i",
           "s",
         }),
         ["<S-Tab>"] = cmp.mapping(function(fallback)
           if cmp.visible() then
             cmp.select_prev_item()
           elseif luasnip.jumpable(-1) then
             luasnip.jump(-1)
           else
             fallback()
           end
         end, {
           "i",
           "s",
         }),
       },
       formatting = {
         fields = { "kind", "abbr", "menu" },
         format = function(entry, vim_item)
           -- Kind icons
           vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
           -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
           vim_item.menu = ({
             nvim_lsp = "[LSP]",
             nvim_lua = "[NVIM_LUA]",
             luasnip = "[Snippet]",
             buffer = "[Buffer]",
             path = "[Path]",
           })[entry.source.name]
           return vim_item
         end,
       },
       sources = {
         { name = "nvim_lsp" },
         { name = "nvim_lua" },
         { name = "luasnip" },
         { name = "buffer" },
         { name = "path" },
       },
       confirm_opts = {
         behavior = cmp.ConfirmBehavior.Replace,
         select = false,
       },
       window = {
         documentation = cmp.config.window.bordered()
       },
       experimental = {
         ghost_text = true,
         native_menu = false,
       },
     })

     lsp.setup(function()
        local signs = {
          { name = "DiagnosticSignError", text = "" },
          { name = "DiagnosticSignWarn", text = "" },
          { name = "DiagnosticSignHint", text = "" },
          { name = "DiagnosticSignInfo", text = "" },
        }

        for _, sign in ipairs(signs) do
          vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
        end

        local config = {
          -- disable virtual text
          virtual_text = true,
          -- show signs
          signs = {
            active = signs,
          },
          update_in_insert = true,
          underline = true,
          severity_sort = true,
          float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        }

        vim.diagnostic.config(config)

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = "rounded",
        })

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = "rounded",
        })
      end)

     require("lsp_lines").setup()

     vim.diagnostic.config({
       virtual_text = false,
     })

     vim.diagnostic.config({ virtual_lines = true })

     vim.keymap.set(
       "",
       "<Leader>l",
       require("lsp_lines").toggle,
       { desc = "Toggle lsp_lines" }
     )
  end
}
