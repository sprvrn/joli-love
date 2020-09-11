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

function Component:debugLayout(ui)
	for k,v in pairs(self) do
		ui:layoutRow('dynamic', 10, 1)
		ui:label(k.." : "..tostring(v))
	end
end

return Component