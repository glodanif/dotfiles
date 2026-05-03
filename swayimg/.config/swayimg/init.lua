-- Scale to fit, re-fit on resize
swayimg.viewer.set_default_scale("optimal")
swayimg.on_window_resize(function()
	swayimg.viewer.set_fix_scale("optimal")
end)

-- Load all files from same directory
swayimg.imagelist.enable_adjacent(true)

swayimg.enable_decoration(false)
swayimg.text.hide()
swayimg.viewer.set_text("topleft", {})
swayimg.viewer.set_text("topright", {})
swayimg.viewer.set_text("bottomleft", {})
swayimg.viewer.set_text("bottomright", {})

-- Scroll wheel to navigate images
swayimg.viewer.on_mouse("ScrollDown", function()
	swayimg.viewer.switch_image("next")
end)
swayimg.viewer.on_mouse("ScrollUp", function()
	swayimg.viewer.switch_image("prev")
end)
