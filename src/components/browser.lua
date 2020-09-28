--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local Browser = Component:extend(Component)

function Browser:__tostring()
	return "browser"
end

function Browser:new(entity)
	Browser.super.new(self, entity)

	self.list = {}

	self.pointer = nil
	self.current = nil
end
-- setList(p,{"down","up"},{label="Element 1",position={x=10,y=20,z=0},style=nil,method=function(...) end})
function Browser:setList(...)
	local t = {...}
	local scene = self.entity.scene
	for i=1,#t do
		local element = t[i]
		local nxt = i+1
		if nxt > #t then
			nxt = 1
		end
		local prv = i-1
		if prv < 1 then
		    prv = #t
		end
		element.activationKey = self.activationKey
		local entityelement = scene:newentity(
			element.label,
			element.position.x + self.position.x,
			element.position.y + self.position.y,
			element.position.z)
			:addComponent("BrowserElement",element,self)
		if type(self.navkeys) == "table" then
		    entityelement:getComponent("browserelement"):add(self.navkeys[1],nxt)
			entityelement:getComponent("browserelement"):add(self.navkeys[2],prv)
		end
		
		table.insert(self.list, entityelement:getComponent("browserelement"))
	end
	
	if #self.list >= 1 then
	    self:setCurrent(self.list[1])
	end
end

function Browser:setKeys(navkeys,activationKey)
	self.activationKey = activationKey
	self.navkeys = navkeys
end

function Browser:setPointer(ox,oy,...)
	local scene = self.entity.scene
	ox = ox or 0
	oy = oy or 0
	local entitypointer = scene:newentity("pointer",self.position.x,self.position.y,self.position.z-1)
		:addComponent("BrowserPointer", ox, oy)
	self.pointer = entitypointer:getComponent("BrowserPointer")

	local args = {...}
	if #args > 0 then
	    if args[1] == "shape" or args[1] == "sprite" then
	        entitypointer:addComponent("Renderer", ...)
	    end
	end
end

function Browser:clickable()
	for i=1,#self.list do
		local element = self.list[i]
		element.entity:addComponent("Collider",element.width,element.height)
		element.entity:addComponent("BrowserClickable")
	end
end

function Browser:setCurrent(element)
	if self.current and self.current.entity:getComponent("Renderer") then
		local render = self.current.entity:getComponent("Renderer")
		if render.rendertype == "text" then
	    render.render:setStyle(self.current.style)
		end
	end
	
	self.current = element
	self.pointer:setPosition(self.current)

	if self.current.entity:getComponent("SoundSet") then
		if self.current.entity:getComponent("SoundSet").sources.nav then
			self.current.entity:getComponent("SoundSet").sources.nav:play()
		end
	end

	if self.current.entity:getComponent("Renderer") then
		local render = self.current.entity:getComponent("Renderer")
		if render.rendertype == "text" then
	    render.render:setStyle(self.current.hoverstyle or self.current.style)
		end
	end
end

function Browser:update(dt)
	if tostring(self.current) == "browserelement" then
	    self.current:updateElement(dt,self)
	end
end

function Browser:draw()
end

--function Browser:debugLayout(ui)
--end

return Browser