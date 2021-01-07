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

	love.run = function()
		if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
	 
		if love.timer then love.timer.step() end
	 
		local dt = 0
		local lf = 0
	 
		return function()
			if love.event then
				love.event.pump()
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "quit" then
						if not love.quit or not love.quit() then
							return a or 0
						end
					end
					love.handlers[name](a,b,c,d,e,f)
				end
			end
	 
			if love.timer then dt = love.timer.step() end
	 
			if love.update then love.update(dt) end

			while love.timer.getTime() - lf < 1 / game.settings.maxfps do
		      love.timer.sleep(.0001)
		    end
	 
			if love.graphics and love.graphics.isActive() then
				love.graphics.origin()
				love.graphics.clear(love.graphics.getBackgroundColor())
	 
				if love.draw then love.draw() end
	 
				love.graphics.present()
			end

		    lf = love.timer.getTime()
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

