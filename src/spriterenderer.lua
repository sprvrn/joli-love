local Render = require "src.renderer"
local anim8 = require "libs.anim8"
local Sprite = require "src.sprite"

local lg = love.graphics

local SpriteRenderer = Render:extend(Render)

function SpriteRenderer:__tostring()
	return "spriterenderer"
end

function SpriteRenderer:new(sprite, anim, ox, oy)
	SpriteRenderer.super.new(self)

	self.sprite = sprite

	self.animToPlay = anim

	self.ox = ox or 0
	self.oy = oy or 0

	if self.sprite.anims then
	    for name, anim in pairs(self.sprite.anims) do
			self.sprite.anims[name] = {
				frame_ct = anim.frame_ct,
				a8 = anim8.newAnimation(self.sprite.grid(anim.range,anim.row), anim.duration)
			}
		end
	end
end

function SpriteRenderer:draw(position, ox, oy, kx, ky)
	SpriteRenderer.super.draw(self)

	local x, y, z, r, sx, sy = position:get()
	x,y = self:getPosition(x,y,ox,oy)

	if self.animToPlay then
		local anim = self.sprite.anims[self.animToPlay] 
		if anim then
		    anim.a8:draw(self.sprite.image, x, y, r, sx, sy, nil, nil, kx, ky)
		end
	else
	    lg.draw(self.sprite.image, x, y, r, sx, sy, nil, nil, kx, ky)
	end

	if self.tint then
	    lg.setColor(1,1,1,1)
	end
end

function SpriteRenderer:update(dt)
	if self.animToPlay then
		local anim = self.sprite.anims[self.animToPlay] 
		if anim then
		    anim.a8:update(dt)
		end
	end
end

function SpriteRenderer:setAnim(name, t, dur)
	local anim = self.sprite.anims[name]
	if anim ~= nil then
		if dur == nil then
		    dur = anim.a8.totalDuration
		else
	    	anim.a8.totalDuration = dur / anim.frame_ct
		end

		anim.a8.status = "playing"
		if t == "once" then
		    anim.a8.onLoop = 'pauseAtEnd'
		end
		anim.a8:gotoFrame(1)

		self.animToPlay = name
	end
end

function SpriteRenderer:debugLayout(ui)
	SpriteRenderer.super.debugLayout(self,ui)
	ui:layoutRow('dynamic', 20, 1)
	ui:label("Animation : "..tostring(self.animToPlay))
	self.sprite:debugLayout(ui)
end

return SpriteRenderer