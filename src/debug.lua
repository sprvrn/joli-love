local Object = require "libs.classic"
local debugGraph = require 'libs.debugGraph'

local Debug = Object:extend()

local lg = love.graphics

function Debug:new()
	self.active = true
	self.fpsGraph = debugGraph:new('fps', 0, 0)
	self.memGraph = debugGraph:new('mem', 0, 30)
end

function Debug:update(dt)
	if not self.active then
	    return
	end
	self.fpsGraph:update(dt)
	self.memGraph:update(dt)
end

function Debug:draw()
	if not self.active then
	    return
	end
		
		lg.setColor(1, 1, 1, 0.8)
		lg.rectangle("fill", 0, 0, 200, 175)
		lg.setColor(0,0,0 ,1)
		lg.push()
		lg.scale(2, 2)
		self.fpsGraph:draw()
		self.memGraph:draw()
		lg.scale(1, 1)
		lg.pop()
		lg.setColor(1, 1, 1, 1)
end

return Debug