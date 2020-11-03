local Component = require "src.components.component"

local Parallax = Component:extend()

function Parallax:__tostring()
	return "parallax"
end

function Parallax:new(entity, camera, speed, ...)
	Parallax.super.new(self, entity)

	self.lockX = false
	self.lockY = false

	self.entity:addComponent("Renderer")
	local renderer = self.entity.renderer
	renderer:add("topleft", ...)
	renderer:add("topright", ...)
	renderer:add("bottomleft", ...)
	renderer:add("bottomright", ...)

	self.width = renderer:get("topleft").sprite.size.w
	self.height = renderer:get("topleft").sprite.size.h

	self.camera = camera
	self.speed = speed or 1
end

function Parallax:update(dt)
	if self.camera then
	    self:setPosition(self.camera.x / self.speed, self.camera.y / self.speed)
	end
end

function Parallax:setPosition(x,y)
	local xm, ym = x % self.width, y % self.height
	local left, top = -xm, -ym

	local topleftx, toplefty = left, top
	local toprightx, toprighty = topleftx + self.width, toplefty
	local bottomleftx, bottomlefty = topleftx, toplefty + self.height
	local bottomrightx, bottomrighty = toprightx, bottomlefty

	local renderer = self.entity.renderer
	renderer:get("topleft"):setOffset(topleftx+self.camera.x, toplefty+self.camera.y)
	renderer:get("topright"):setOffset(toprightx+self.camera.x, toprighty+self.camera.y)
	renderer:get("bottomleft"):setOffset(bottomleftx+self.camera.x, bottomlefty+self.camera.y)
	renderer:get("bottomright"):setOffset(bottomrightx+self.camera.x, bottomrighty+self.camera.y)
end

return Parallax