
return {
    "hrsh7th/nvim-cmp",
    -- info: temp fix
    commit = "b356f2c",

    -- lazy = true,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "uga-rosa/cmp-dynamic",

        "saadparwaiz1/cmp_luasnip",
        { "max397574/cmp-greek", lazy = true },

        -- { "kdheepak/cmp-latex-symbols", lazy = true },
        { "hrsh7th/cmp-emoji", lazy = true },
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local icons = require("dvmujic.icons")

        -- require("dvmujic.plugins.cmp.umlaut").setup()

        cmp.setup {
            sources = cmp.config.sources({
                { name = "umlaut" },
                { name = "crates" },
            },
            {
                { name = "nvim_lsp" },
            },

            -- dont show other cmps when lsp is available
            {
                { name = "calc" },
                { name = "dynamic" },
                { name = "greek", max_item_count = 5 },
                { name = "luasnip", keyword_length = 2 },
                { name = "emoji" },
            },
            {
                { name = "buffer", keyword_length = 2 },
            }),

            snippet = {
                expand = function(args) luasnip.lsp_expand(args.body) end
            },
            window = {
                completion = {
                    col_offset = 0,
                    -- winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    -- side_padding = 0,
                },
            },
            formatting = {
                -- order of the fields
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
                    local comp_icons = icons.comp

                    local menu_types = {
                        nvim_lsp = "[lsp]",
                        luasnip = "[luasnip]",
                        greek = "[greek]",
                        umlaut = "[umlaut]",

                        latex_symbols = "[latex]",
                        buffer = "[buffer]",
                    }

                    vim_item.kind = string.format("%s (%s)", comp_icons[vim_item.kind], vim_item.kind)
                    vim_item.menu =  menu_types[entry.source.name]
                    return vim_item
                end
            },
            mapping = {
                ["<Up>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    else fallback() end
                end, { "i", "s" }),
                ["<Down>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    else fallback() end
                end, { "i", "s" }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if not cmp.get_selected_entry() then
                            cmp.select_next_item()
                        --elseif cmp.select_next_item() then
                        else
                            cmp.confirm()
                        end
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else fallback() end
                end, { "i", "s" }),
            },
        }

        require("cmp_dynamic").register {
            --[[
            { label = "ue", insertText = function () return "ü" end },
            { label = "Ue", insertText = function () return "Ü" end },
            { label = "ae", insertText = function () return "ä" end },
            { label = "Ae", insertText = function () return "Ä" end },
            { label = "oe", insertText = function () return "ö" end },
            { label = "Oe", insertText = function () return "Ö" end },
            { label = "ss", insertText = function () return "ß" end },
            ]]--
        }

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                {
                    name = "cmdline",
                    option = {
                        ignore_cmds = { "Man", "!" },
                    },
                    keyword_length = 3,
                }
            })
        })

    end,
}

