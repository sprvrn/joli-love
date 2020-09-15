local Object = require "libs.classic"

local Component = Object:extend(Object)

function Component:new(entity)
	self.entity = entity
	self.position = entity.components.position
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
	for k,v in pairs(self) do
		ui:layoutRow('dynamic', 10, 1)
		ui:label(k.." : "..tostring(v))
	end
end

return Component