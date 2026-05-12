--- @param line string
local function get_line_number(line)
    local b = vim.api.nvim_get_current_buf()
    local buf_contents = vim.api.nvim_buf_get_lines(b, 0, -1, false)
    -- find the line with the current todo
    local todo_line = -1
    for i, l in ipairs(buf_contents) do
        if l == line then
            todo_line = i
            break
        end
    end
    return todo_line
end

--- set the sub todos to done
---@param line_num     integer
---@param mark_done    boolean
---@param indent_level integer
--- @return integer? # the line number of the current todo
local function toggle_sub_todos(line_num, mark_done, indent_level)
    local b = vim.api.nvim_get_current_buf()
    local buf_contents = vim.api.nvim_buf_get_lines(b, 0, -1, false)

    local match_indent = "^" .. string.rep("%s", indent_level + 2)
    for i = line_num + 1, #buf_contents, 1 do
        local l = buf_contents[i]
        if l:match(match_indent) or l:len() == 0 then
            if mark_done then
                l = l:gsub("%[%s*%]", "[x]", 1)
            else
                l = l:gsub("%[x%]", "[]", 1)
            end
            vim.api.nvim_buf_set_lines(b, i - 1, i, true, { l })
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

    local line_num = get_line_number(line)
    if unchecked then
        if mark_sub then
            toggle_sub_todos(line_num, true, indent_level)
        end
        line = line:gsub("%[%s*%]", "[x]", 1)
    elseif checked then
        if mark_sub then
            toggle_sub_todos(line_num, false, indent_level)
        end
        line = line:gsub("%[x%]", "[]", 1)
    end

    -- set the current line to the new line
    vim.api.nvim_set_current_line(line)

    -- check if all todos in a context are complete
    if line_num and indent_level >= 2 then
        local b = vim.api.nvim_get_current_buf()
        local buf_contents = vim.api.nvim_buf_get_lines(b, 0, -1, false)

        local parent_indent = "^" .. string.rep("%s", indent_level - 2)
        local parent_todo_line = nil
        -- loop backwards to find the parent todo
        for i = line_num - 1, 1, -1 do
            local l = buf_contents[i]
            if l:match(parent_indent .. "-%s*%[.*%]%s") then
                parent_todo_line = i
                break
            end
        end

        -- if no parent todo found, return
        if not parent_todo_line then
            return
        end

        -- loop through all sub todos and check if they are all complete
        local all_sub_todos_complete = true
        local match_indent = "^" .. string.rep("%s", indent_level)
        for i = parent_todo_line + 1, #buf_contents, 1 do
            local l = buf_contents[i]
            -- if the line is a sub todo, check if it is complete
            if l:match(match_indent) then
                if not l:match("%[x%]") then
                    all_sub_todos_complete = false
                    break
                end
            elseif l:match("^%s*$") then
            else
                break
            end
        end

        -- mark the parent todo as complete if all sub todos are complete
        if all_sub_todos_complete then
            local parent_line = buf_contents[parent_todo_line]
            parent_line = parent_line:gsub("%[%s*%]", "[x]", 1)
            vim.api.nvim_buf_set_lines(b, parent_todo_line - 1, parent_todo_line, true, { parent_line })
        end
    end
end

local M = {}

function M.setup()
    vim.api.nvim_create_augroup("TODO", { clear = true })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = "TODO",
        pattern = "*.todo",
        callback = function()
            vim.bo.filetype = "todo"
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
