--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"
local Camera = require "src.camera"
local Entity = require "src.entity"
local bump = require "libs.bump"

local lg = love.graphics

local Scene = Entity:extend(Entity)

function Scene:new(name)
	Scene.super.new(self,name)

	self.cameras = {}

	self.entities = {}

	self.world = nil

	self:addCamera("main",0,0,
		game.settings.canvas.width,
		game.settings.canvas.height,
		0,
		game.settings.canvas.scale)
end

function Scene:newentity(name, ...)
	local sortByZ = function(a,b)
		return a.position.z < b.position.z
	end
	local sortByName = function(a,b)
		return a.name < b.name
	end

	local newEntity = Entity(name, ...)
	newEntity.scene = self
	if self[name] then
		--print("Warning : an entity named " .. name .. " already exists.")
	end
	table.insert(self.entities, newEntity)

	table.sort(self.entities, sortByName)
	table.sort(self.entities, sortByZ)

	self[name] = newEntity
	return newEntity
end

function Scene:initPrefab(prefab, ...)
	if type(prefab) == "function" then
		return prefab(self, ...)
	else
		print("Warning : a prefab couldn't be loaded.")
	end
end

function Scene:getEntityByName(name)
	for _,e in pairs(self.entities) do
		if name == e.name then
			return e
		end
	end
end

function Scene:removeentity(entity)
	if entity.collider and self.world then
		self.world:remove(entity.collider)
	end
	self[entity.name] = nil
	table.remove(self.entities, getIndex(self.entities,entity))
end

function Scene:addCamera(name,...)
	self.cameras[name] = Camera(self,name,...)
end

function Scene:createPhysicWorld()
	if self.world == nil then
		self.world = bump.newWorld()
	end
end

function Scene:addCollider(item)
	self.world:add(item, item.x, item.y, item.w, item.h)
end

function Scene:update(dt)
	Scene.super.update(self,dt)

	if self.pause then
		return
	end

	for _,camera in pairs(self.cameras) do
		camera:update(dt)

		if self.world and game.settings.mouse then
			local mx, my = camera:mousePosition()
			local items, len = self.world:queryPoint(mx, my, function(item)
				if tostring(item) == "collider" then
					return true
				end
			end)

			for i=1,len do
				local item = items[i]
				item.mousehover = true
			end
		end
	end

	for i=1,#self.entities do
		local entity = self.entities[i]
		if entity then
		    entity:update(dt)
		end
	end
end

function Scene:drawentities(tags,mode)
	if self.hide then
		return
	end
	mode = mode or "incl"
	if type(tags) == "string" then
		tags = {tags}
	end
	for i=1,#self.entities do
		local entity = self.entities[i]
		if entity then
		    if  (tags ~= nil and mode == "incl" and table.contains(tags,entity.tag)) or
				(tags ~= nil and mode == "excl" and not table.contains(tags,entity.tag)) or
				tags == nil then

				entity:draw()
			end
		end
	end
end

function Scene:particle(system,x,y,z,tag)
	local rate = system.rate or 1
	for i=1,rate do
		local particle = self:addParticle(x,y,z,
			system.colors[math.floor(love.math.random(1,#system.colors))],
			love.math.random(system.lifetime[1],system.lifetime[2])
			)
		particle.entity.tag = tag
		particle:velocityx(system.vx[1],system.vx[2],system.vx[3])
		particle:velocityy(system.vy[1],system.vy[2],system.vy[3])
		particle:size(system.size[1],system.size[2],system.size[3])

		if system.collider then
			particle.entity:addComponent("Collider",10,10)
		end
	end
	
end

function Scene:addParticle(x,y,z,color,size,exp)
	local particle = self:newentity("particle_entity",x,y,z)
		:addComponent("Particle",color or {1,1,1,1},exp or 1)

	return particle.particle
end

function Scene:setPause(pause)
	--if pause then
		self.pause = pause
		for _,e in pairs(self.entities) do
			local set = e:getComponent("SoundSet")
			if set then
				if pause then
					set:pause()
				else
					set:resume()
				end
			end
		end
	--end
end

return Scene