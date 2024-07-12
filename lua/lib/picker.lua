local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local finders = require("telescope.finders")
local term = require("toggleterm.terminal")
local ttr = require("lib.stuff")

M = {}

function set_active(prompt_bufnr, map)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    ttr.set_active(selection.value.id)
end

function M.open()
    local opts = {
        finder = finders.new_table {
            results = term.get_all(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.display_name,
                    ordinal = entry.id,
                }
            end,
        },
        sorter = sorters.get_generic_fuzzy_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(set_active)
            return true
        end
    }

    local repls = pickers.new(opts, {})

    repls:find()
end

return M
