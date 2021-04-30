--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local SpriteRenderer = require "src.spriterenderer"
local ShapeRenderer = require "src.shaperenderer"
local TextRenderer = require "src.textrenderer"
local BatchRenderer = require "src.batchrenderer"

local Renderer = Component:extend()

function Renderer:__tostring()
	return "renderer"
end

function Renderer:new(entity, ...)
	Renderer.super.new(self, entity)

	self.list = {}
	self.order = {}

	local args = {...}

	if #args > 0 then
		self:add("default", ...)
	end
end

function Renderer:add(name, ...)
	assert(type(name)=="string")

	local args = {...}

	if not table.contains(self.order,name) then
	    table.insert(self.order, name)
	end

	if tostring(args[1]) == "sprite" then
		self.list[name] = SpriteRenderer(...)
	elseif type(args[1]) == "string" then
		if args[1] == "rect" or args[1] == "circ" or args[1] == "line" then
			self.list[name] = ShapeRenderer(...)
		else
			self.list[name] = TextRenderer(...)
		end
	end
	-- TODO batch renderer

	return self.list[name]
end

function Renderer:get(name)
	return self.list[name]
end

function Renderer:setOrder(...)
	local o = {}
	for _,name in pairs({...}) do
		if type(name) == "string" then
		    table.insert(o, name)
		end
	end
	self.order = o
end

function Renderer:setOrderPosition(name,i)
	local shift = function(t, old, new)
	    local value = t[old]
	    if new < old then
	       table.move(t, new, old - 1, new + 1)
	    else    
	       table.move(t, old + 1, new, old) 
    end
	    t[new] = value
	end

	shift(self.order, getIndex(self.order,name), i)
end

function Renderer:getDimensions()
	for _,r in pairs(self.list) do
		if r.rendertype == "sprite" then
			
		end
	end
end

function Renderer:draw(ox, oy)
	for i=1,#self.order do
		local render = self.list[self.order[i]]
		if render and not render.hide then
			local x, y, z, r, sx, sy = self.position:get()
			render:draw(self.position, x + (ox or 0), y + (oy or 0), z, r, sx, sy)
		end
	end
end

function Renderer:update( dt )
	for i=1,#self.order do
		local render = self.list[self.order[i]]
		if render then
			render:update(dt)
		end
	end
end

return Renderer