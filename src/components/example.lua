--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local NewComponent = Component:extend()

function NewComponent:__tostring()
	return "newcomponent"
end

function NewComponent:new(entity, ...)
	NewComponent.super.new(self, entity)
end

function NewComponent:update(dt)
end

function NewComponent:draw()
end

function NewComponent:debugLayout(ui)
end

return NewComponent