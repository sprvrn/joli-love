local Render = require "src.renderer"
local reflowprint = require "libs.reflowprint.init"

local lg = love.graphics

local TextRenderer = Render:extend(Render)

function TextRenderer:__tostring()
	return "textrenderer"
end

function TextRenderer:new(text,style,width,align)
	TextRenderer.super.new(self)

	self.text = tostring(text)
	self.width = width or game.assets.settings.canvas.width
	self.style = style or game.assets.fonts.main
	self.tint = self.style.color or {1,1,1,1}
	self.align = align or "left"
	self.progress = 1
end

function TextRenderer:draw(position,ox,oy)
	TextRenderer.super.draw(self)

	local x,y,z,r,sx,sy = position:get()
	x,y = self:getPosition(x,y,ox,oy)
	lg.setFont(self.style.font)
	reflowprint(self.progress,self.text,x,y,self.width,self.align)

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
end

function TextRenderer:update(dt)
	self.progress = self.progress + dt
	if self.progress >= 1 then
	    self.progress = 1
	end
end

return TextRenderer