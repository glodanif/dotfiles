-- Display mode persisted by monitors-layout-toggle ("pc" or "tv"). Read here so the
-- compositor can declare the right monitor/workspace layout on its first frame,
-- instead of always coming up in PC mode and having monitors-layout-restore
-- reconfigure it a beat later (which costs an extra modeset — see the FRL notes).
local base = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")

local mode = "pc"
local f = io.open(base .. "/hypr-display-mode", "r")
if f then
	local line = f:read("*l")
	f:close()
	if line and line:match("^%s*(%S+)%s*$") == "tv" then
		mode = "tv"
	end
end

return mode
