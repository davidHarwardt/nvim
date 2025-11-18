
vim.cmd[[autocmd BufRead,BufEnter *.typ set filetype=typst]]

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.wgsl",
    callback = function() vim.bo.filetype = "wgsl" end,
})


