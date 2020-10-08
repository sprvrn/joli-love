--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local lg = love.graphics

local Particle = Component:extend()

function Particle:__tostring()
	return "particle"
end

function Particle:new(entity,color,exp,particletype,options)
	Particle.super.new(self,entity)

	self.entity:cron("after",exp,function()
		self.entity.scene:removeentity(self.entity)
	end)

	self.expire = exp

	options = options or {}

	if type(particletype) == "string" then
		self.entity:addComponent("Renderer",
			particletype,
			options.style or "main",
			options.width or 100,
			options.align or "left")
		if color then
		    self.entity.renderer:get("default").tint = color
		end
	elseif tostring(particletype) == "sprite" then
		self.entity:addComponent("Renderer",particletype,options.anim,0,0,options.flipx,options.flipy)
		if color then
		    self.entity.renderer:get("default").tint = color
		end
	else
		self.entity:addComponent("Renderer","circ", color or nil, "fill", size)
	end

	self.render = self.entity.renderer:get("default")
end

function Particle:velocityx(easing,vx1,vx2)
	vx1 = vx1 or 0
	vx2 = vx2 or vx1
	self.entity:tween(self.expire,{x = self.position.x + love.math.random(vx1,vx2)},easing or 'linear',self.position)
end

function Particle:velocityy(easing,vy1,vy2)
	vy1 = vy1 or 0
	vy2 = vy2 or vy1
	self.entity:tween(self.expire,{y = self.position.y + love.math.random(vy1,vy2)},easing or 'linear',self.position)
end

function Particle:size(easing,startsize,endsize)
	if self.render.rendertype == "shape" then
	    self.render.arg1 = startsize
		if endsize then
			self.entity:tween(self.expire,{arg1 = endsize},easing or 'linear', self.render)
		end
	elseif self.render.rendertype == "sprite" or self.render.rendertype == "text" then
	    self.position.scalex = startsize
	    self.position.scaley = startsize
		if endsize then
			self.entity:tween(self.expire,{scalex = endsize,scaley = endsize},easing or 'linear', self.position)
		end
	end
end

function Particle:alpha(easing,s,e)
	if not self.render.tint then
	    self.render.tint = {1,1,1,s}
	    self.render.alpha = s
	else
	    self.render.tint = {self.render.tint[1],self.render.tint[2],self.render.tint[3],s}
	    self.render.alpha = s
	end
	if e then
		self.entity:tween(self.expire,{alpha = e},easing or 'linear', self.render)
	end
end

function Particle:update(dt)
	
end

return Particle