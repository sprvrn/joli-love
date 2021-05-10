local Component = require "src.components.component"

local Parallax = Component:extend()

function Parallax:__tostring()
	return "parallax"
end

function Parallax:new(entity, camera, speedX, speedY, ...)
	Parallax.super.new(self, entity)

	if not self.entity.renderer then
	    self.entity:addComponent("Renderer")
	end
	
	local renderer = self.entity.renderer
	renderer:add("topleft", ...)
	renderer:add("topright", ...)
	renderer:add("bottomleft", ...)
	renderer:add("bottomright", ...)

	self.width = renderer:get("topleft").sprite.size.w
	self.height = renderer:get("topleft").sprite.size.h

	self.camera = camera

	self.speedX = speedX or 1
	self.speedY = speedY or 1

	self.lockX = false
	self.lockY = false
end

function Parallax:update(dt)
	if self.camera then
		local x,y = self.camera.x, self.camera.y
		if not self.lockX then
		    x = x / self.speedX
		else
		    x = 0
		end
		if not self.lockY then
		    y = y / self.speedY
		else
		    y = 0
		end
	    self:setPosition(x,y)
	end
end

function Parallax:setPosition(x,y)
	local xm, ym = x % self.width, y % self.height
	local left, top = -xm, -ym

	local topleftx, toplefty = left, top
	local toprightx, toprighty = topleftx + self.width, toplefty
	local bottomleftx, bottomlefty = topleftx, toplefty + self.height
	local bottomrightx, bottomrighty = toprightx, bottomlefty

	--if not self.lockX then
	    topleftx, toprightx, bottomleftx, bottomrightx = topleftx+self.camera.x, toprightx+self.camera.x, bottomleftx+self.camera.x, bottomrightx+self.camera.x
	--[[else
	    topleftx, toprightx, bottomleftx, bottomrightx = self.camera.x,self.camera.x,self.camera.x,self.camera.x
	end]]
	--if not self.lockY then
	    toplefty, toprighty, bottomlefty, bottomrighty = toplefty+self.camera.y, toprighty+self.camera.y, bottomlefty+self.camera.y, bottomrighty+self.camera.y
	--[[else
	    toplefty, toprighty, bottomlefty, bottomrighty = self.camera.y,self.camera.y,self.camera.y,self.camera.y
	end]]

	local renderer = self.entity.renderer
	renderer:get("topleft"):setOffset(topleftx, toplefty)
	renderer:get("topright"):setOffset(toprightx, toprighty)
	renderer:get("bottomleft"):setOffset(bottomleftx, bottomlefty)
	renderer:get("bottomright"):setOffset(bottomrightx, bottomrighty)
end

return Parallax