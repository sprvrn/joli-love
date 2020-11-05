--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local lg = love.graphics

local Renderer = Object:extend()

function Renderer:__tostring()
	return "renderer"
end

function Renderer:new(tint, ox , oy)
	self.tint = tint or {1,1,1,1}
	--self.alpha = self.tint[4] or 1

	self.ox = ox or 0
	self.oy = oy or 0
end

function Renderer:draw()
	if self.tint then
		if self.alpha then
		    self.tint[4] = self.alpha
		end
	    lg.setColor(self.tint)
	end
end

function Renderer:update(dt)
end

function Renderer:setOffset(ox,oy)
	if ox then
	    self.ox = ox
	end
	if oy then
	    self.oy = oy
	end
end

function Renderer:getPosition(x,y,ox,oy)
	return x+(ox or self.ox),y+(oy or self.oy)
end

return Renderer