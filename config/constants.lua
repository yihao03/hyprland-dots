local M = {}

M.terminal = "ghostty +new-window"
M.file_manager = "nautilus"
M.noct_prefix = "noctalia msg"
M.menu = M.noct_prefix .. " panel-toggle launcher"
M.browser = "brave-origin-nightly"
M.main_mod = "SUPER" -- Sets "Windows" key as main modifier
M.default_layout = "scrolling" -- "dwindle", "master", "scrolling"

M.timeout = {
	short = 1500,
	medium = 3000,
	long = 5000,
}

return M
