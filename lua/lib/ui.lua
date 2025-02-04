local List = require("lib.list")
local term = require("toggleterm.terminal")

-- shamelessly copied and then modified from harpoon (https://github.com/ThePrimeagen/harpoon)
function M._create_window()
    local height = 8
    local width = 69
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>q<cr>", {})
    vim.api.nvim_buf_set_keymap(bufnr, "n", "A", "<cmd>lua print(require('toggleterm-repl').ui._selected_term())<cr>", {})
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        title = "Open ToggleTerms and REPLs",
        --title_pos = toggle_opts.title_pos or "left",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "double",
        --border = toggle_opts.border or "single",
    })
    local ttlist = List:new()
    for _,t in pairs(term.get_all()) do
        ttlist:append(t.id, t.name, nil)
        -- print(vim.inspect(t))
    end
    local contents = ttlist:display()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)
end


function M._selected_term()
    local line = vim.api.nvim_get_current_line()
    local term_id = string.gsub(line, "[:].*$", "")
    return term_id
end

-- M._create_window()
return M
