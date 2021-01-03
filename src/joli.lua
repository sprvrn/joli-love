local joli = {
_VERSION = '0.3',
_DESCRIPTION = 'small framework for love2d',
_URL = 'https://github.com/sprvrn/joli-love',
_LICENSE = [[
MIT License

Copyright (c) 2020 sprvrn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
}

function joli.new()
	io.stdout:setvbuf("no")
	
	game = require("src.game")()
	game:start()

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
					local sx, sy = w / game.settings.canvas.width, h / game.settings.canvas.height
					if sx < sy then
						sy = sx
					else
						sx = sy
					end
					camera.position.scalex = sx
					camera.position.scaley = sy
				end
			end
		end
	end
end

return joli