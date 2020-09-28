local Joli = require "src.joli"

love.load = function()
	game = Joli.new()
	game:start()
end

love.update = function(dt)
	game:update(dt)
end

love.draw = function()
	game:draw()
end