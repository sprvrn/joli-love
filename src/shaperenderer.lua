--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"

local lg = love.graphics

local ShapeRenderer = Render:extend(Render)

local shapefunc = {
	rect = lg.rectangle,
	circ = lg.circle
}

function ShapeRenderer:__tostring()
	return "shaperenderer"
end

function ShapeRenderer:new(type, color, mode, arg1, arg2)
	ShapeRenderer.super.new(self)

	self.rendertype = "shape"

	self.type = type
	self.mode = mode or "fill"
	self.arg1 = arg1
	self.arg2 = arg2
	self.tint = color
end

function ShapeRenderer:draw(position,ox,oy)
	ShapeRenderer.super.draw(self)
	local x, y, z, r, sx, sy = position:get()
	x, y = self:getPosition(x,y,ox,oy)

	lg.push()
	
	lg.scale(sx,sy)

	shapefunc[self.type](self.mode, x, y, self.arg1, self.arg2)

	lg.pop()

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
end

function ShapeRenderer:debugLayout(ui)
	ShapeRenderer.super.debugLayout(self,ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label("Type : "..self.type)
	ui:label("Mode : "..self.mode)
	if self.type == "rect" then
	    ui:layoutRow('dynamic', 20, 2)
	    self.arg1 = ui:property("Width", 0, self.arg1, 10000000, 1, 1)
		self.arg2 = ui:property("Height", 0, self.arg2, 10000000, 1, 1)
	end
	if self.type == "circ" then
	    ui:layoutRow('dynamic', 20, 1)
	    self.arg1 = ui:property("Radius", -10000000, self.arg1, 10000000, 1, 1)
	end
end

return ShapeRenderer