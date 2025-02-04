local M = {}

M.picker = require("lib.picker")
M.list = require("lib.list")
M.stuff = require("lib.stuff")
M.ui = require("lib.ui")

function M.setup(opts)
    M.stuff.setup_commands()
end

return M
