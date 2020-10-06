--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local TiledMapLayer = Component:extend()

local lg = love.graphics

function TiledMapLayer:__tostring()
	return "tiledmaplayer"
end

function TiledMapLayer:new(entity, layer)
	TiledMapLayer.super.new(self, entity)

	self.layer = layer
end

function TiledMapLayer:update(dt)
	self.layer:update(dt)
end

function TiledMapLayer:draw()
	local x,y = self.position:get()
	lg.push()
	lg.translate(x, y)
	self.layer:draw()
	lg.pop()
end

return TiledMapLayer