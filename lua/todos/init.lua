---@param line         string
---@param mark_done    boolean
---@param indent_level integer
local function toggle_sub_todos(line, mark_done, indent_level)
    local b = vim.api.nvim_get_current_buf()
    local buf_contents = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    -- set the sub todos to done
    -- find the line with the current todo
    local todo_line = -1
    for i, l in ipairs(buf_contents) do
        if l == line then
            todo_line = i + 1
            break
        end
    end

    -- return if no lines found
    if todo_line < 0 then
        return
    end

    -- mark sub todos as complete
    local match_indent = "^" .. string.rep("%s", indent_level + 2)
    for i = todo_line, #buf_contents, 1 do
        local l = buf_contents[i]
        if l:match(match_indent) then
            if mark_done then
                l = l:gsub("%[.*%]", "[x]", 1)
                vim.api.nvim_buf_set_lines(b, i - 1, i, true, { l })
            else
                l = l:gsub("%[x%]", "[]", 1)
                vim.api.nvim_buf_set_lines(b, i - 1, i, true, { l })
            end
        else
            break
        end
    end
end

-- au BufRead,BufNewFile *.todo set filetype=todo
---@param mark_sub boolean?
local function toggle_todo(mark_sub)
    local line = vim.api.nvim_get_current_line()
    local unchecked = line:match("^%s*-%s*%[%s*%]%s")
    local checked = line:match("^%s*-%s*%[x%]%s")

    local indent_level = 0
    for _, l in ipairs(vim.split(line, "")) do
        if l == " " then
            indent_level = indent_level + 1
        else
            break
        end
    end

    if unchecked then
        if mark_sub then
            toggle_sub_todos(line, true, indent_level)
        end
        line = line:gsub("%[%s*%]", "[x]", 1)
    elseif checked then
        if mark_sub then
            toggle_sub_todos(line, false, indent_level)
        end
        line = line:gsub("%[x%]", "[]", 1)
    end

    vim.api.nvim_set_current_line(line)
end

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
            vim.keymap.set("n", "tT", function()
                toggle_todo(true)
            end, { desc = "toggle the todo (and sub todos)" })

            -- leader ta adds a - [] to the current line
            vim.keymap.set("n", "<leader>ta", "_i- [] <Esc>", { desc = "add a todo item" })
        end,
    })
end

return M
