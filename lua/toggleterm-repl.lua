
local term = require("toggleterm.terminal")
local Terminal = term.Terminal
local rlangrepl = { cmd = "R", direction = "horizontal", hidden = false, repl_type = "rlang"} 
function pyreplopts()
    return { cmd = "ipython", direction = "horizontal", hidden = false , repl_type = "python"}
end
TT_FOCUSED_REPL = nil

BFT = vim.bo.filetype

function _update_buf_ft(bft)
    if(bft ~= "toggleterm") then
        BFT = bft
    end
end

-- Local function from toggleterm.terminal that I needed to copy/paste here to use
-- in giving new terminals the correct index
function term_next_id()
    local all = term.get_all(true)
    for index, term in pairs(all) do
        if index ~= term.id then return index end
    end
    return #all + 1
end

function get_term_by(key, value)
    local all = term.get_all(true)
    local matches = {}
    for index, term in pairs(all) do
        if term[key] == value then matches[index] = term end
    end
    return matches
end

function send_line()
    require("toggleterm").send_lines_to_terminal("single_line", false, {args = TT_FOCUSED_REPL})
end

function _new_repl(termopts, display_name, make_focused)
    make_focused = make_focused or true
    display_name = display_name or "python"
    termopts["display_name"] = display_name
    termopts["id"] = term_next_id()
    local repl = Terminal:new(termopts)
    if (make_focused) then
        TT_FOCUSED_REPL = repl["id"]
    end
    return repl
end

function _create_or_toggle_repl()
    _update_buf_ft(vim.bo.filetype)
    if (BFT == "python") then
        local pyrepls = get_term_by("repl_type", BFT)
        if(#pyrepls == 0) then
            _new_repl(pyreplopts(), "python", true):open()
        else
            if(#pyrepls ==  1) then
                pyrepls[1]:toggle()
                TT_FOCUSED_REPL = pyrepls[1]["id"]
            else
                vim.cmd("Telescope toggleterm_mananger")
            end
        end
    elseif(BFT == "R") then
        rterm:toggle()
    else
        vim.cmd("ToggleTerm")
    end
end

