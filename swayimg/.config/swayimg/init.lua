-- Scale to fit, re-fit on resize
swayimg.viewer.default_scale = "fit"
swayimg.on_window_resize(function()
	swayimg.viewer.set_fix_scale("fit")
end)

-- Load all files from same directory
swayimg.imagelist.adjacent = true

swayimg.decoration = false
swayimg.text.visible = false
swayimg.viewer.text = { topleft = {}, topright = {}, bottomleft = {}, bottomright = {} }

-- Scroll wheel to navigate images
swayimg.viewer.on_scroll(function(_, _, vertical)
	if vertical > 0 then
		swayimg.viewer.open("next")
	elseif vertical < 0 then
		swayimg.viewer.open("prev")
	end
end)
