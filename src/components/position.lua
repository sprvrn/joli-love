local Component = require "src.components.component"

local Position = Component:extend(Component)

function Position:__tostring()
	return "position"
end

function Position:new(entity,x,y,z,r,sx,sy)
	Position.super.new(self,entity)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.r = r or 0
	self.scalex = sx or 1
	self.scaley = sy or 1
end

function Position:get()
	local x,y,z,r,sx,sy = self.x,self.y,self.z,self.r,self.scalex,self.scaley
	
	if self.shakex then
	    x = x + self.shakex
	end
	if self.shakey then
	    y = y + self.shakey
	end

	return x,y,z,r,sx,sy
end

function Position:scale(x,y)
	x = x or 1
	y = y or x
	self.scalex,self.scaley = x,y
end

function Position:move(x,y)
	local collider = self.entity.collider
	local x, y = x, y
	if collider then
	    x, y = collider:move(x, y)
	end
	self.x = x
	self.y = y
end

function Position:debugLayout(ui)
	ui:layoutRow('dynamic', 20, 3)
	self.x = ui:property("x", -10000000, self.x, 10000000, 1, 1)
	self.y = ui:property("y", -10000000, self.y, 10000000, 1, 1)
	self.z = ui:property("z", -10000000, self.z, 10000000, 1, 1)
	ui:layoutRow('dynamic', 20, 1)
	self.r = ui:property("Rotation", -10000000, self.r, 10000000, 1, 1)
	ui:layoutRow('dynamic', 20, 2)
	self.scalex = ui:property("Scale X", -10000000, self.scalex, 10000000, 1, 1)
	self.scaley = ui:property("Scale Y", -10000000, self.scaley, 10000000, 1, 1)
end

return Position