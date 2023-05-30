return {
    "navarasu/onedark.nvim",
    priority = 98,
    -- dependencies = { "levouh/tint.nvim" },
    config = function()
        require("onedark").setup {
            style = "cool",
        }
        require("onedark").load()
        -- require("tint").refresh()
    end
}
