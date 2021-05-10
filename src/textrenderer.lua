--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Render = require "src.renderer"
local Text = require "libs.slog-text"

local lg = love.graphics

local TextRenderer = Render:extend(Render)

function TextRenderer:__tostring()
	return "textrenderer"
end

function TextRenderer:new(text,style,width,align,ox,oy,settings)
	TextRenderer.super.new(self, nil, ox, oy)

	self.rendertype = "text"

	style = style or "main"

	self.text = tostring(text)
	self.previoustxt = self.text

	self.width = width or game.assets.settings.canvas.width
	self.style = game.assets.fonts[style]
	self.tint = self.style.color or {1,1,1,1}

	self.align = align or "left"
	
	self.showall = true

	self.settings = settings or {}

	self:setStyle(style)

	self.textbox = Text.new(self.align, self.settings)

	Text.configure.icon_table("Icon")

	self:changeText(self.text)
end

function TextRenderer:setStyle(name)
	assert(type(name) == "string")
	self.style = game.assets.fonts[name]

	self.settings.font = self.style.font
	self.settings.color = self.style.color

	local tags = ""

	local addTag = function(param, tag)
		tag = tag or param
		
		if self.style[param] then
		    tags = tags .. string.format("[%s=%s]", tag, self.style[param])
		end
	end
	
	addTag("shadow", "dropshadow")
	addTag("shadowcolor")
	addTag("shake")
	addTag("spin")
	addTag("swing")
	addTag("raindrop")
	addTag("bounce")
	addTag("blink")
	addTag("rainbow")

	self.settings.autotags = tags

	self.textbox = Text.new(self.align, self.settings)

	self:changeText(self.text)
end

function TextRenderer:draw(position, x, y, z, r, sx, sy, ox, oy)
	TextRenderer.super.draw(self)

	x,y = self:getPosition(x,y,ox,oy)
	
	if self.style.font then
	    lg.setFont(self.style.font)
	end

	if self.clip then
	    lg.setScissor(position.x+self.clip.x,position.y+self.clip.y,self.clip.width,self.clip.height)
	end
	
	lg.push()
	lg.scale(sx, sy)

	self.textbox:draw(x,y)
	
	lg.pop()

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
	if self.clip then
	    lg.setScissor()
	end
end

function TextRenderer:changeText(txt)
	txt = tostring(txt)

	self.text = txt
	self.previoustxt = txt

	if game.assets.sprites[game.settings.iconimg] then
	    for name,anim in pairs(game.assets.sprites[game.settings.iconimg].anims) do
	    	local n = string.upper(name)
	    	self.text = string.gsub(self.text, string.upper(name), tostring(anim.id))
	    end
	end

	self.textbox:send(self.text, self.width, self.showall)
end

function TextRenderer:update(dt)
	self.textbox:update(dt)
	if self.previoustxt ~= self.text then
		self:changeText(self.text)
	end
end

return TextRenderer