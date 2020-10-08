--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]
local Object = require "libs.classic"

local Component = Object:extend()

function Component:new(entity)
	self.entity = entity
	self.position = entity.position
end

function Component:update(dt)
end

function Component:draw()
end

function Component:onRightClick()
end

function Component:onLeftClick()
end

function Component:onMiddleClick()
end

function Component:hover()
end

function Component:hoverEnter()
end

function Component:hoverQuit()
end

function Component:onStay(other)
end

function Component:onEnter(other)
end

function Component:onLeave(other)
end

function Component:debugLayout(ui)
	layout(ui,self)
end

function layout(ui,tab)
	for k,v in pairs(tab) do
		if k ~= "position" and k ~= "entity" then
		    local t = type(v)
			if t == "number" then
				ui:layoutRow('dynamic', 20, 1)
			    tab[k] = ui:property(k, -10000000, tab[k], 10000000, 1, 1)
			elseif t == "string" then
				ui:layoutRow('dynamic', 25, 2)
			    ui:label(k)
			    --ui:label(v)
			    ui:edit('field', {value=tab[k]})
			elseif t == "table" then
				if ui:treePush('node',k.." #"..#v.." "..tostring(v)) then
					layout(ui,v)
					ui:treePop()
				end
			elseif t == "boolean" then
				ui:layoutRow('dynamic', 20, 1)
				tab[k] = ui:checkbox(k, tab[k])
			else
			    ui:layoutRow('dynamic', 20, 2)
			    ui:label(k)
			    ui:label(tostring(v))
			end
		end
	end
end

return Component