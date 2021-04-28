--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"
local tween = require "libs.tween"
local cron = require "libs.cron"

local lg = love.graphics

local Entity = Object:extend()

function Entity:__tostring()
	return "entity:"..self.name
end

function Entity:new(name, x, y, z, layer, tag)
	assert(type(name) == "string", "Entity name must be a string (was "..type(name)..")")

	self.name = name

	self.tag = tag
	self.layer = layer
	self.components = {}

	self.tweens = {}
	self.crons = {}

	self:addComponent("position",x,y,z,r,sx,sy)

	self.pause = false
	self.hide = false

	self.scene = nil
end

function Entity:setPause(pause)
	self.pause = pause

	if pause then
		table.remove(self.scene.updatedEntities, getIndex(self.scene.updatedEntities, self))
	else
	    if not table.contains(self.scene.updatedEntities, self) then
	        table.insert(self.scene.updatedEntities, self)
	    end
	end
end

function Entity:setHide(hide)
	self.hide = hide

	if hide then
		table.remove(self.scene.drawnEntities, getIndex(self.scene.drawnEntities, self))
	else
	    if not table.contains(self.scene.drawnEntities, self) then
	        table.insert(self.scene.drawnEntities, self)
	    end
	end
end

function Entity:addComponent(name, ...)
	name = string.lower(name)
	local comp = game:getComponent(name)
	if not comp then
	    print("Warning: fail to add <"..name.."> component : does not exists. (entity : "..self.name..")")
	    return self
	end

	if self[name] then
	    print("Warning: <"..name.."> component is already attached to entity <"..self.name..">")
	else
		local c = comp(self, ...)
		table.insert(self.components, c)
		self[name] = c
	end

	return self
end

function Entity:removeComponent(name)
	name = string.lower(name)
	for k,v in pairs(self.components) do
		if tostring(v) == name then
		    table.remove(self.components, getIndex(self.components,v))
		    self[name] = nil
		end
	end
end

function Entity:update(dt)
	if self.pause then
	    return
	end
	for i=1,#self.components do
		local component = self.components[i]
		component:update(dt)
	end

	self:updateshake(dt)

	for i=1,#self.crons do
		local cron = self.crons[i]
		if cron then
		    local expired = cron:update(dt)
			if expired then
				table.remove(self.crons, getIndex(self.crons, cron))
			end
		end
	end
	for i=1,#self.tweens do
		local tween = self.tweens[i]
		if tween then
		    local expired = tween:update(dt)
			if expired then
				table.remove(self.tweens, getIndex(self.tweens, tween))
			end
		end
	end
end

function Entity:draw(filter)
	if self.hide then
	    return
	end

	for i=1,#self.components do
		local component = self.components[i]
		component:draw()
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
	--self.pause = not self.pause
	--self.hide = not self.hide
	self:setPause(not self.pause)
	self:setHide(not self.hide)
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