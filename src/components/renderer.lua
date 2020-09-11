local Component = require "src.components.component"

local SpriteRenderer = require "src.spriterenderer"
local ShapeRenderer = require "src.shaperenderer"
local TextRenderer = require "src.textrenderer"
local BatchRenderer = require "src.batchrenderer"

local Renderer = Component:extend(Component)

local method = {
	sprite = SpriteRenderer,
	text = TextRenderer,
	shape = ShapeRenderer,
	batch = BatchRenderer
}

function Renderer:__tostring()
	return "renderer"
end

function Renderer:new(entity, type, ...)
	Renderer.super.new(self, entity)
	self.render = method[type](...)
end

function Renderer:draw()
	self.render:draw(self.position)
end

function Renderer:update( dt )
	self.render:update(dt)
end

function Renderer:debugLayout(ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label(tostring(self.render))
	self.render:debugLayout(ui)
end

return Renderer