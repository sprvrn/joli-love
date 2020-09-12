local Component = require "src.components.component"

local lg = love.graphics

local Collider = Component:extend(Component)

function Collider:__tostring()
	return "collider"
end

function Collider:new(entity, w, h, solid, x, y)
	Collider.super.new(self, entity)

	self.ox = x or 0
	self.oy = y or 0

	self:updatePosition()

	self.w = w or 1
	self.h = h or 1

	self.solid = solid

	if not self.entity.scene.world then
	    self.entity.scene:createPhysicWorld()
	end
	self.entity.scene:addCollider(self)

	self.collide = {up=nil,down=nil,left=nil,right=nil}

	self.hidecollider = true
end

function Collider:move(x,y)
	local collidefilter = function(item, other)
		if other.solid then
		    return "slide"
		end

		return "cross"
	end
	local ax, ay, cols, len =  self.entity.scene.world:move(self, x, y, collidefilter)

	self.collide = {up=nil,down=nil,left=nil,right=nil}

	if len ~= 0 then
	    for i=1,len do
	    	local c = cols[i]
	    	if c.normal.y == -1 then
	    	    self.collide.down = c.other
	    	end
	    	if c.normal.y == 1 then
	    		self.collide.up = c.other
	    	end
	    	if c.normal.x == -1 then
	    	    self.collide.right = c.other
	    	end
	    	if c.normal.x == 1 then
	    	    self.collide.left = c.other
	    	end
	    end
	end

	return ax,ay
end

function Collider:updatePosition()
	self.x = self.position.x + (self.ox or 0)
	self.y = self.position.y + (self.oy or 0)
end

function Collider:update(dt)
	self:updatePosition()

	self.entity.scene.world:update(self,self.x,self.y,self.w,self.h)
end

function Collider:draw()
	if self.hidecollider then
	    return
	end
	local x,y,w,h = self.entity.scene.world:getRect(self)
	lg.setColor(0, 1, 0, 1)
	lg.rectangle("line", x,y,w,h)
	lg.setColor(1, 1, 1, 1)
end

function Collider:debugLayout(ui)
	ui:layoutRow('dynamic', 20, 1)
	self.hidecollider = ui:checkbox("Hide", self.hidecollider)
	ui:layoutRow('dynamic', 20, 2)
	self.ox = ui:property("offset X", -10000000, self.ox, 10000000, 1, 1)
	self.oy = ui:property("offset Y", -10000000, self.oy, 10000000, 1, 1)
	ui:layoutRow('dynamic', 20, 2)
	self.w = ui:property("Width", 1, self.w, 10000000, 1, 1)
	self.h = ui:property("Height", 1, self.h, 10000000, 1, 1)
	ui:layoutRow('dynamic', 20, 1)
	self.solid = ui:checkbox("Solid", self.solid)
	ui:label("Colliding with")
	ui:label("  up : "..tostring(self.collide.up))
	ui:label("  down : "..tostring(self.collide.down))
	ui:label("  right : "..tostring(self.collide.right))
	ui:label("  left : "..tostring(self.collide.left))
end

return Collider