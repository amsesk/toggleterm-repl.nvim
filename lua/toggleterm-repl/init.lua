local api = vim.api
local tt = require("toggleterm")
local nn = require("notebook-navigator")
local nn_utils = require("notebook-navigator.utils")
local List = require("toggleterm-repl.list")

local M = {}

local term = require("toggleterm.terminal")
local Terminal = term.Terminal
--local rlangrepl = { cmd = "R", direction = "horizontal", hidden = false, repl_type = "rlang"}

function pyreplopts()
    return { cmd = "ipython --no-autoindent", direction = "horizontal", hidden = false, repl_type = "python" }
end
function rlangreplopts()
    return { cmd = "R", direction = "horizontal", hidden = false, repl_type = "r" }
end

M.REPLOPT = {
    python = pyreplopts,
    r = rlangreplopts,
}

M.active_repl = nil

BFT = vim.bo.filetype

-- shamelessly borrowed from harpoon
function M._create_window()
    local height = 8
    local width = 69
    local bufnr = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        title = "REPLs",
        --title_pos = toggle_opts.title_pos or "left",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "double",
        --border = toggle_opts.border or "single",
    })
    repllist = List:new()
    repllist:append(1, "meh", "nada")
    print(vim.inspect(repllist))
    repllist._length = 1
    local contents = repllist:display()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, contents)
end

function _update_buf_ft(bft)
    if bft ~= "toggleterm" then
        BFT = bft
    end
end

-- Local function from toggleterm.terminal that I needed to copy/paste here to use
-- in giving new terminals the correct index
function term_next_id()
    local all = term.get_all(true)
    for index, term in pairs(all) do
        if index ~= term.id then
            return index
        end
    end
    return #all + 1
end

function M.get_term_by(key, value)
    local all = term.get_all(true)
    local matches = {}
    for index, term in pairs(all) do
        if term[key] == value then
            matches[index] = term
        end
    end
    return matches
end

function M.send_line()
    if M.active_repl == nil then
        M.new_ft_repl()
    end
    require("toggleterm").send_lines_to_terminal("single_line", false, { args = M.active_repl })
end

function M.send_visual()
    if M.active_repl == nil then
        local current_window = api.nvim_get_current_win()
        M.new_ft_repl()
        api.nvim_set_current_win(current_window)
    end
    require("toggleterm").send_lines_to_terminal("visual_selection", false, { args = M.active_repl }, true)
end

function M.run_cell_and_move()
    if M.active_repl == nil then
        local current_window = api.nvim_get_current_win()
        M.new_ft_repl()
        api.nvim_set_current_win(current_window)
    end
    local repl_args = {
        id = M.active_repl,
        -- Trimming spaces here screws up text sent to ipython
        trim_spaces = false,
    }
    nn.run_and_move(repl_args)
end

function M.set_active(id)
    local id = tonumber(id)
    if M.active_repl ~= nil then
        local last_active_term = M.get_term_by("id", M.active_repl)[M.active_repl]
        last_active_term.display_name = string.gsub(last_active_term.display_name, "(*)", "")
    end
    local new_active_term = M.get_term_by("id", id)[id]
    M.active_repl = id
    new_active_term.display_name = string.format("%s %s %s", "***", new_active_term.display_name, "***")
end

function M._new_repl(termopts, display_name, make_focused)
    make_focused = make_focused or true
    display_name = display_name or "python"
    termopts["display_name"] = display_name
    termopts["id"] = term_next_id()
    local repl = Terminal:new(termopts)
    if make_focused then
        M.active_repl = repl["id"]
    end
    return repl
end

function M.new_ft_repl()
    _update_buf_ft(vim.bo.filetype)
    local existing_repls = M.get_term_by("repl_type", BFT)
    local repl_display_name = string.format("%s-%s", BFT, #existing_repls + 1)
    M._new_repl(M.REPLOPT[BFT](), repl_display_name, true):open()
    --if (BFT == "python") then
    --    M._new_repl(pyreplopts(), repl_display_name, true):open()
    --end
end

function M._create_or_toggle_repl()
    _update_buf_ft(vim.bo.filetype)
    if BFT == "python" then
        local pyrepls = M.get_term_by("repl_type", BFT)
        if #pyrepls == 0 then
            M._new_repl(pyreplopts(), "ipython", true):open()
        else
            if #pyrepls == 1 then
                pyrepls[1]:toggle()
                M.active_repl = pyrepls[1]["id"]
            else
                vim.cmd("Telescope toggleterm_mananger")
            end
        end
    elseif BFT == "r" then
        local rlangrepls = M.get_term_by("repl_type", BFT)
        if #rlangrepls == 0 then
            M._new_repl(rlangreplopts(), "r", true):open()
        else
            if #rlangrepls == 1 then
                rlangrepls[1]:toggle()
                M.active_repl = rlangrepls[1]["id"]
            else
                vim.cmd("Telescope toggleterm_mananger")
            end
        end
    else
        tt.toggle_command()
    end
end

local function setup_commands()
    local command = api.nvim_create_user_command
    command("ReplSetActive", function(opts)
        M.set_active(opts.fargs[1])
    end, { nargs = 1 })
    command("ReplGetActive", function()
        print(M.active_repl)
    end, {})
    command("ToggleTermFtReplNew", function()
        M.new_ft_repl()
    end, {})
end

function M.setup(opts)
    setup_commands()
end

return M
