--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"
local reflowprint = require "libs.reflowprint"

local lg = love.graphics

local TextRenderer = Render:extend(Render)

function TextRenderer:__tostring()
	return "textrenderer"
end

function TextRenderer:new(text,style,width,align,ox,oy)
	TextRenderer.super.new(self, nil, ox, oy)

	style = style or "main"

	self.text = tostring(text)
	self.width = width or game.assets.settings.canvas.width
	self.style = game.assets.fonts[style]
	self.tint = self.style.color or {1,1,1,1}
	self.align = align or "left"
	self.progress = 1

	self.rendertype = "text"
end

function TextRenderer:setStyle(name)
	assert(type(name) == "string")
	self.style = game.assets.fonts[name]
	self.tint = self.style.color or {1,1,1,1}
end

function TextRenderer:draw(position, x, y, z, r, sx, sy,ox,oy)
	TextRenderer.super.draw(self)

	--local x,y,z,r,sx,sy = position:get()
	x,y = self:getPosition(x,y,ox,oy)
	
	if self.style.font then
	    lg.setFont(self.style.font)
	end

	if self.clip then
	    lg.setScissor(position.x+self.clip.x,position.y+self.clip.y,self.clip.width,self.clip.height)
	end
	
	lg.push()
	lg.scale(sx, sy)
	reflowprint(self.progress,self.text,x,y,self.width,self.align)
	lg.pop()

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
	if self.clip then
	    lg.setScissor()
	end
end

function TextRenderer:update(dt)
	self.progress = self.progress + dt
	if self.progress >= 1 then
	    self.progress = 1
	end
end

return TextRenderer