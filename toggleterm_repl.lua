return require("telescope").register_extension {
    exports = {
        toggleterm_repl = require("lib.picker").open
    },
}
