--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"
local ShapeRenderer = require "src.shaperenderer"
local TextRenderer = require "src.textrenderer"

local lg = love.graphics

local Particle = Component:extend()

function Particle:__tostring()
	return "particle"
end

function Particle:new(entity,color,exp,t,style)
	Particle.super.new(self,entity)

	self.entity:cron("after",exp,function()
		self.entity.scene:removeentity(self.entity)
	end)

	self.expire = exp

	if type(t) == "string" then
	    self.renderer = TextRenderer(t, style or "main", 100, "left")
	else
	    self.renderer = ShapeRenderer("circ", color or nil, "fill", size)
	end
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

function Particle:size(startsize,endsize,easing)
	self.renderer.arg1 = startsize
	if endsize then
	    self.entity:tween(self.expire,{arg1 = endsize},easing or 'linear', self.renderer)
	end
end

function Particle:update(dt)
	
end

function Particle:draw()
	self.renderer:draw(self.position)
end

function Particle:debugLayout(ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label("Expire : " .. tostring(self.expire))
	self.renderer:debugLayout(ui)
end

return Particle