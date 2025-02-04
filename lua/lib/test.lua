term = require("toggleterm.terminal")
ttrep = require("toggleterm-repl").stuff

print(vim.inspect(term.get_all()))
vim.ui.select(
    ttrep.get_all_repls(true),
    {
        prompt = "Select which REPL to set active:",
        format_item = function(item)
            return item.name
        end,
    },
    function(selected) 
    end
)
