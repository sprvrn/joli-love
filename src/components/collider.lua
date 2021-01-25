--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local lg = love.graphics

local Collider = Component:extend()

function Collider:__tostring()
	return "collider"
end

function Collider:new(entity, w, h, solid, ox, oy)
	Collider.super.new(self, entity)

	self.ox = ox or 0
	self.oy = oy or 0

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

	self.mousehover = false
	self.dragable = false

	self.doubleclick = false

	self.prevFrameCol = {}
end

function Collider:move(x,y)
	local collidefilter = function(item, other)
		if other.solid then
			return "slide"
		end

		return "cross"
	end
	local ax, ay, cols, len = self.entity.scene.world:move(self, x, y, collidefilter)

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

	return ax, ay
end

function Collider:updatePosition()
	self.x = self.position.x + (self.ox or 0)
	self.y = self.position.y + (self.oy or 0)
end

function Collider:update(dt)
	self:updatePosition()

	local world = self.entity.scene.world

	if not world:hasItem(self) then
		return
	end

	world:update(self,self.x,self.y,self.w,self.h)

	-- collision with mouse
	local components = self.entity.components
	if self.mousehover then
		if not self.lastframehover then
			for _,c in pairs(components) do
				c:hoverEnter()
			end
			self.lastframehover = true
		end

		for _,c in pairs(components) do
			c:hover()
		end

		if game.input:pressed("leftclick") then
			if self.doubleclick then
				for _,c in pairs(components) do
					c:onDoubleClick()
				end
			end
			for _,c in pairs(components) do
				c:onLeftClick()
				self.clicked = {x=0,y=0}
				self.doubleclick = true
				self.entity:cron("after",0.2,function()self.doubleclick = false end)
			end
		end
		if game.input:pressed("rightclick") then
			for _,c in pairs(components) do
				c:onRightClick()
			end
		end
		if game.input:pressed("middleclick") then
			for _,c in pairs(components) do
				c:onMiddleClick()
			end
		end
	end

	if self.dragable then
		if game.input:down("leftclick") then
		    
		else
		    self.clicked = nil
		end
	end

	if not self.mousehover then
		if self.lastframehover then
			for _,c in pairs(components) do
				c:hoverQuit()
			end
		end
		self.lastframehover = false
	end

	if not world:hasItem(self) then
		return
	end

	self.mousehover = false
	-- end mouse
	-- collision with entity
	local colWith = {}
	local x,y,w,h = world:getRect(self)
	local items, tlen = world:queryRect(x,y,w,h)

	for i=1,tlen do
		local item = items[i].entity
		if self.entity ~= item then
			if not table.contains(self.prevFrameCol,item) then
				for _,c in pairs(components) do
					c:onEnter(item)
				end
				if not table.contains(self.prevFrameCol,item) then
					table.insert(self.prevFrameCol, item)
				end
			end
			for _,c in pairs(components) do
				c:onStay(item)
			end
			table.insert(colWith, item)
		end
	end

	for _,prevState in pairs(self.prevFrameCol) do
		if not table.contains(colWith,prevState) then
			for _,c in pairs(components) do
				c:onLeave(prevState)
			end
			table.remove(self.prevFrameCol, getIndex(self.prevFrameCol, prevState))
		end
	end
	-- end collision entity
end

function Collider:draw()
	if self.hidecollider then
		return
	end
	if not world:hasItem(self) then
		return
	end
	local x,y,w,h = world:getRect(self)
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
	self.solid = ui:checkbox("Solid", self.solid or false)
	ui:label("Colliding with")
	ui:label("  up : "..tostring(self.collide.up))
	ui:label("  down : "..tostring(self.collide.down))
	ui:label("  right : "..tostring(self.collide.right))
	ui:label("  left : "..tostring(self.collide.left))
end

return Collider