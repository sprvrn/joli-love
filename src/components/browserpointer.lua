--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local BrowserPointer = Component:extend()

function BrowserPointer:__tostring()
	return "browserpointer"
end

function BrowserPointer:new(entity,ox,oy)
	BrowserPointer.super.new(self, entity)
	self.offsetx = ox or 0
	self.offsety = oy or 0
end

function BrowserPointer:update(dt)
end

function BrowserPointer:draw()
end

function BrowserPointer:setPosition(element)
	local position = self.position

	position.x = element.position.x + self.offsetx
	position.y = element.position.y + self.offsety
	
end

return BrowserPointer