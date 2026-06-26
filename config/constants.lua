local terminal = "ghostty +new-window"
local fileManager = "nautilus"
local noctPrefix = "qs -c noctalia-shell ipc call"
local menu = noctPrefix .. " launcher toggle"
local browser = "brave-origin-nightly"
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

return {
	terminal = terminal,
	fileManager = fileManager,
	noctPrefix = noctPrefix,
	menu = menu,
	browser = browser,
	mainMod = mainMod,
}
