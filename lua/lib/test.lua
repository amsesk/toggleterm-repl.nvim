term = require("toggleterm.terminal")
to = require("toggleterm-repl").stuff.replopts.python
to["id"] = 4
print(vim.inspect(to))

term.Terminal:new(to):open()
local all = term.get_all()
print(vim.inspect(#all))

