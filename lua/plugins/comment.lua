return {
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup {
            ---Add a space b/w comment and the line
      padding = true,
      ---Whether the cursor should stay at its position
      sticky = true,
      ---NOTE: If given `false` then the plugin won't create any mappings
      mappings = {
          ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
          basic = true,
          ---Extra mapping; `gco`, `gcO`, `gcA`
          extra = true,
      },
      -- pre_hook = function(ctx)
      --   local U = require "Comment.utils"
      --
      --   local location = nil
      --   if ctx.ctype == U.ctype.block then
      --     location = require("ts_context_commentstring.utils").get_cursor_location()
      --   elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      --     location = require("ts_context_commentstring.utils").get_visual_start_location()
      --   end
      --
      --   return require("ts_context_commentstring.internal").calculate_commentstring {
      --     key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      --     location = location,
      --   }
      -- end,
    }
  end
}
