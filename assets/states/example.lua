return {
	update = function(dt)
		local scene = game.scene_game
		scene:update(dt)
	end,

	draw = function()
		local scene = game.scene_game
		local camera = scene.cameras.main
		
		camera:set()
		scene:drawentities("ui","excl")
		camera:unset()
		scene:drawentities("ui","incl")
		camera:draw()
	end,

	on_enter = function()
		local scene = game:newscene("scene_game")
	end,

	on_exit = function()
		game.scene_game = nil
	end
}