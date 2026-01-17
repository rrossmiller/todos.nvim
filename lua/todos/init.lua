-- au BufRead,BufNewFile *.todo set filetype=todo
local function toggle_todo()
    local line = vim.api.nvim_get_current_line()
    local unchecked = line:match("^%s*-%s*%[%s*%]%s")
    local checked = line:match("^%s*-%s*%[x%]%s")

    if unchecked then
        line = line:gsub("%[%s*%]", "[x]", 1)
    elseif checked then
        line = line:gsub("%[x%]", "[]", 1)
    end

    vim.api.nvim_set_current_line(line)
end

-- Placeholder for future expansion
-- Exposes a setup() function for Lazy.nvim

local M = {}

function M.setup()
    vim.api.nvim_create_augroup("TODO", { clear = true })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = "TODO",
        pattern = "*.todo",
        callback = function()
            vim.bo.filetype = "todo"
            vim.o.textwidth = 110
            vim.keymap.set("n", "tt", toggle_todo, { desc = "toggle the todo" })

            -- leader ta adds a - [] to the current line
            vim.keymap.set("n", "<leader>tt", "_i- [] <Esc>", { desc = "add a todo item" })

        end,
    })
end

return M
