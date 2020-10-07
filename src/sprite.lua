--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"
local anim8 = require "libs.anim8"

local lg = love.graphics

local Sprite = Object:extend()

function Sprite.load(img)
	return Sprite(img)
end

function Sprite.get(file)
	local f = strsplit(file,"/")
	local name = strsplit(f[#f],".")

	local sprites = require("assets.sprites")
	for _,img in pairs(sprites) do
		if name[1] == img.name then
		    return img
		end
	end
end

function Sprite:__tostring()
	return "sprite"
end

function Sprite:new(filepath)
	local img = Sprite.get(filepath)

	self.image = lg.newImage(filepath)
	self.image:setFilter('nearest', 'nearest')

	self.path = filepath

	self.size = { w=self.image:getWidth(), h=self.image:getHeight() }

	if img then
	    sprWidth = img.spriteW or 0
		sprHeight = img.spriteH or 0
		self.grid = {}
		self.anims = {}
		self.size = { w=sprWidth, h=sprHeight }

		if sprWidth ~= 0 and sprHeight ~= 0 then
		    self.grid = anim8.newGrid(sprWidth, sprHeight, self.image:getWidth(), self.image:getHeight())
		end
	 
		if img.anims then
			for name,anim in pairs(img.anims) do
				local r = 1
				anim.start = anim.start or 1
				anim.stop = anim.stop or anim.start
				anim.dur = anim.dur or 1
				self.anims[name] = {
					name = name,
					frame_ct = anim.stop - anim.start + 1,
					range = anim.start.."-"..anim.stop,
					row = r,
					duration = anim.dur
				}
			end
		end
	end
end

function Sprite:debugLayout(ui)
	ui:layoutRow('dynamic', 175, 1)
	if ui:groupBegin('Sprite','title','scrollbar','border') then
		ui:layoutRow('dynamic', 20, 1)
		ui:label(self.path)
		ui:layoutRow('dynamic', 20, 2)
		ui:label("Img width : "..tostring(self.image:getWidth()))
		ui:label("Img height : "..tostring(self.image:getHeight()))
		if self.size then
		    ui:layoutRow('dynamic', 20, 2)
			ui:label("Sprite width : "..tostring(self.size.w))
			ui:label("Sprite height : "..tostring(self.size.h))
			ui:layoutRow('dynamic', 20, 1)
			ui:label("Animations")
			for name,anim in pairs(self.anims) do
				ui:label(" - "..name)
			end
		end
		
		ui:groupEnd()
	end
end

return Sprite