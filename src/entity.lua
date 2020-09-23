local Object = require "libs.classic"
local tween = require "libs.tween"
local cron = require "libs.cron"

local lg = love.graphics

local Entity = Object:extend(Object)

function Entity:__tostring()
	return "entity:"..self.name
end

function Entity:new(name, x, y, z, r, sx, sy, tag)
	assert(type(name) == "string","Entity name must be a string (was "..type(name)..")")

	self.name = name

	self.tag = tag
	self.components = {}

	self.tweens = {}
	self.crons = {}

	self:addComponent("position",x,y,z,r,sx,sy)

	self.pause = false
	self.hide = false

	self.scene = nil
end

function Entity:addComponent(name, ...)
	name = string.lower(name)
	local comp = game:getComponent(name)
	if not comp then
	    print("Warning, fail to add <"..name.."> component : does not exists. ("..self.name..")")
	    return self
	end

	local c = comp(self, ...)
	self.components[name] = c
	self[name] = c

	return self
end

function Entity:getComponent(name)
	assert(type(name)=="string")
	
	name = string.lower(name)
	for _,component in pairs(self.components) do
		if name == tostring(component) then
		    return component
		end
	end
end

function Entity:update(dt)
	if self.pause then
	    return
	end
	for _,c in pairs(self.components) do
		c:update(dt)
	end

	self:updateshake(dt)

	for _,cron in pairs(self.crons) do
		local expired = cron:update(dt)
		if expired then
			table.remove(self.crons, getIndex(self.crons,cron))
		end
	end
	for _,tween in pairs(self.tweens) do
		local expired = tween:update(dt)
		if expired then
			table.remove(self.tweens, getIndex(self.tweens,tween))
		end
	end
end

function Entity:draw(filter)
	if self.hide then
	    return
	end

	for _,c in pairs(self.components) do
		c:draw()
	end
end

function Entity:cron(type, delay, callback, ...)
	local call = cron.after
	if type == "every" then call = cron.every end

	local c = call(delay, callback, ...)
	table.insert(self.crons, c)
	return c
end

function Entity:tween(duration, target, easing, subject)
	local t = tween.new(duration, subject or self, target, easing)
	table.insert(self.tweens, t)
	return t
end

function Entity:toggle()
	self.pause = not self.pause
	self.hide = not self.hide
end

function Entity:shake(duration,magnitudex,magnitudey)
	self.shakeduration = duration or 1
	self.magnix = magnitudex or 0
	self.magniy = magnitudey or 0
	self:tween(duration,{shakeduration=0})
end

function Entity:updateshake(dt)
	if self.shakeduration and self.shakeduration > 0 then
		self.position.shakex = love.math.random(-self.magnix, self.magnix)
		self.position.shakey = love.math.random(-self.magniy, self.magniy)
	else
		self.position.shakex = 0
		self.position.shakey = 0
	end
end

return Entity