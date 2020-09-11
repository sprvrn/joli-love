local Game = require "src.game"

love.load = function()
	game = Game()

	game:change_state("game")
end

love.update = function(dt)
	game:update(dt)
end

love.draw = function()
	game:draw()
end

love.resize = function(w, h)
	--game:writeSettings(w,h)
end