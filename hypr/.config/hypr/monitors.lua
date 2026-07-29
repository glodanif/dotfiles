local mode = require("display-mode")

if mode == "tv" then
	-- Come up at "preferred" (the TV advertises @60 while waking); settle_tv upgrades
	-- to @120 once the panel actually offers it. Forcing @120 here would reintroduce
	-- the wake-up mode flap that kills GPU clients.
	hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "0x0", scale = "2" })
	hl.monitor({ output = "DP-1", disabled = true })
	hl.monitor({ output = "DP-2", disabled = true })
else
	hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "0x0", scale = "1" })
	hl.monitor({ output = "DP-1", mode = "2560x1440@59.951", position = "1920x0", scale = "1" })
	hl.monitor({ output = "HDMI-A-1", disabled = true })
end
