local Object = require "libs.classic"

local Example = Object:extend()

function Example:new()
	Example.super.new(self)
end

function Example:onEnter()
	local scene = game:newscene("scene_game")
end

function Example:onExit()
	game.scene_game = nil
end

function Example:update(dt)
	game.scene_game:update(dt)
end

function Example:draw()
	local scene = game.scene_game
	local camera = scene.cameras.main
		
	camera:set()
	scene:drawentities("ui","excl")
	camera:unset()
	scene:drawentities("ui","incl")
	camera:draw()
end

return Example