--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local BrowserClickable = Component:extend(Component)

function BrowserClickable:__tostring()
	return "newcomponent"
end

function BrowserClickable:new(entity)
	BrowserClickable.super.new(self, entity)
end

function BrowserClickable:onLeftClick()
	local element = self.entity:getComponent("BrowserElement")
	if element and element.onActivation then
	    element.onActivation(element)
	end
end

function BrowserClickable:hoverEnter()
	local element = self.entity:getComponent("BrowserElement")
	if element then
		element.browser:setCurrent(element)
	end
end

return BrowserClickable