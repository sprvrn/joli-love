--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local Clickable = Component:extend()

function Clickable:__tostring()
	return "clickable"
end

function Clickable:new(entity, ...)
	Clickable.super.new(self, entity)
end

function Clickable:update(dt)
end

function Clickable:draw()
end

function Clickable:debugLayout(ui)
end

return Clickable