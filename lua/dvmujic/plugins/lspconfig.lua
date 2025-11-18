
return {
    "neovim/nvim-lspconfig",
    config = function()
        -- error diagnostics (dont show virtual text in diagnostics)
        vim.diagnostic.config {
            virtual_text = false,
            signs = true,
            underline = true,
        }

        -- setup diagnostic icons
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        local lspconfig = require("lspconfig")
        local caps = vim.lsp.protocol.make_client_capabilities()
        caps = require("cmp_nvim_lsp").default_capabilities(caps)
        caps.textDocument.completion.completionItem.snippetSupport = false
        -- `true` to enable auto-imports for rust-analzyer
        caps.textDocument.completion.completionItem.additionalTextEdits = true

        local flags = { debounce_text_changes = 150 }

        vim.g.zig_fmt_autosave = 0 -- disable format on autosave for zig lang-server
        
        local servers = {
            -- misc
            marksman = {},      -- markdown
            -- typst_lsp = {},       -- typst
            tinymist = {
                exportPdf = "onSave"
            },
            nil_ls = {},        -- nix

            -- programming-langs
            clangd = {},        -- c/cpp
            gopls = {},         -- go
            zls = {},           -- zig
            ocamllsp = {},      -- ocaml (ocamllsp)
            hls = {},           -- haskell
            gleam = {},         -- gleam
            rust_analyzer = {   -- rust
                ["rust-analyzer"] = {
                    cargo = { autoreload = true },
                    completion = {
                        autoimport = { enable = false },
                    },
                },
            },
            -- metals = {},
            pyright = {},

            -- web
            ts_ls = {}, -- replacement for tsserver = {},
            -- denols = {},
            svelte = {},
            tailwindcss = {},
            -- cssls = {},

            -- dsls
            -- pest_ls = {},
            slint_lsp = {},
            astro = {},
            wgsl_analyzer = {},
            taplo = {},
            csharp_ls = {},

            lua_ls = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = {"vim"} },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                    telemetry = { enable = false },
                },
            },

            sourcekit = {},
            --[[ harper_ls = {
                ["harper-ls"] = {
                    linters = {
                        sentence_capitalization = false,
                        number_suffix_capitalization = false,
                        spaces = false,
                    }
                }
            } ]]--
        }

        for k, v in pairs(servers) do
            lspconfig[k].setup {
                capabilities = caps,
                -- offset_encoding = "utf-8",
                flags = flags,
                settings = v,
            }
        end

        local allow_snippets = caps
        allow_snippets.textDocument.completion.completionItem.snippetSupport = true

        lspconfig.cssls.setup { capabilities = allow_snippets, flags = flags }
        -- lspconfig.html.setup { capabilities = allow_snippets, flags = flags }

        -- emmet
        --[[ lspconfig.emmet_language_server.setup {
            capabilities = allow_snippets,
            flags = flags,
            settings = {
                includeLanguages = {
                    javascriptreact = "html",
                    typescriptreact = "html",
                    javascript = "html",
                    typescript = "html",
                }
            }
        } ]]--

        lspconfig.arduino_language_server.setup {
            capabilities = caps,
            flags = flags,
            offset_encoding = "utf-8",
            cmd = {
                "arduino-language-server",
                "-cli-config",
                "$HOME/.arduinoIDE/arduino-cli.yaml"
            }
        }

        lspconfig.clangd.setup {
            capabilities = caps,
            flags = flags,
            cmd = { "clangd", "--offset-encoding=utf-16" }
        }

        -- see options: https://github.com/aca/emmet-ls
        lspconfig.emmet_ls.setup {
            capabilities = allow_snippets,
            flags = flags,
            filetypes = {
                "css", "html", "javascriptreact",
                "typescriptreact", "vue"
            },
            init_options = {
                jsx = {
                    options = {
                        ["markup.attributes"] = {
                            className = "class",
                            htmlFor = "for",
                        },
                    },
                },
            },
        }

        require("dvmujic.plugins.lspconfig.custom")

        -- attach
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                vim.opt.signcolumn = "yes"

                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

                vim.keymap.set("n", "gb", "<C-o>", opts)

                vim.keymap.set("n", "<leader>l", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
            end,
        })
    end
}

