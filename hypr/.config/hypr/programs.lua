-- Programs used across the config. Unlike hyprlang's global $vars, Lua modules
-- have to hand these back explicitly — require("programs") to use them.
return {
	terminal = "ghostty",
	fileManager = "thunar",
	menu = "walker",
	browser = "brave-origin",
	tasks = "btop",
}
