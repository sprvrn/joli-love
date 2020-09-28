--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"

local lg = love.graphics

local BatchRenderer = Render:extend(Render)

local shapefunc = {
	rect = lg.rectangle,
	circ = lg.circle
}

function BatchRenderer:__tostring()
	return "batchrenderer"
end

function BatchRenderer:new(batch)
	BatchRenderer.super.new(self)

	self.batch = batch
end

function BatchRenderer:draw(position,ox,oy)
	BatchRenderer.super.draw(self)
	local x, y, z, r, sx, sy = position:get()
	x, y = self:getPosition(x,y,ox,oy)

	lg.push()
	
	lg.scale(sx,sy)

	lg.draw(self.batch, x, y)

	lg.pop()

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
end

return BatchRenderer