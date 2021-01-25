return {
	identity = "test",

	window = {
		title = "joli",
		icon = "src/joli_icon/joli.png",
		minwidth = 1,
		minheight = 1,
		borderless = false,
		resizable = true,
		fullscreen = false,
		fullscreentype = "desktop",
		vsync = 0
	},
	canvas = {
		width = 256,
		height = 192,
		scale = 4,
		scaletowindow = true
	},
	maxfps = 120,

	debug = true,
	
	mouse = true,

	autobatch = false,
	batchmaxsprites = 1000,

	-- game specific settings
}