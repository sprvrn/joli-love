local eventcall = {
	"keypressed",
	"keyreleased",
	"mousepressed",
	"mousereleased",
	"mousemoved",
	"textinput",
	"wheelmoved"
}

local set = function()
	love.update = function(dt)
		game:update(dt)
	end

	love.draw = function()
		game:draw()
	end

	love.resize = function(w,h)
		if game.settings.scaletowindow then
			for _,scene in pairs(game.scenes) do
				for _,camera in pairs(scene.cameras) do
					camera:resizeToWindow(w,h)
				end
			end
		end
	end

	for _,name in pairs(eventcall) do
		love[name] = function(...)
			if game.gui then
			    game.gui.ui[name](game.gui.ui,...)
			end
		end
	end
end

return set

