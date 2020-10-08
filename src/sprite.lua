--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]
local json = require "libs.json"
local Object = require "libs.classic"
local anim8 = require "libs.anim8"

local lg, lf = love.graphics, love.filesystem

local Sprite = Object:extend()

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

	local p = strsplit(filepath, ".")
	local jsonfile = p[1]..".json"

	local n = strsplit(p[1],"/")
	self.name = n[#n]

	self.image:setFilter('nearest', 'nearest')

	self.path = filepath

	self.size = { w=self.image:getWidth(), h=self.image:getHeight() }

	if lf.getInfo(jsonfile) then
	    local data = json.decode(lf.read(jsonfile))

	    if data.meta.app == "http://www.aseprite.org/" then
	        self.grid = {}
			self.anims = {}
			self.size = { w=data.frames[1].sourceSize.w, h=data.frames[1].sourceSize.h }

			if sprWidth ~= 0 and sprHeight ~= 0 then
			    self.grid = anim8.newGrid(self.size.w, self.size.h, data.meta.size.w, data.meta.size.h)
			end

			for i=1,#data.meta.frameTags do
				local a = data.meta.frameTags[i]

				a.from = a.from + 1
				a.to = a.to + 1

				local durations = {}

				for i=a.from,a.to do
					table.insert(durations, data.frames[i].duration / 1000)
				end

				self.anims[a.name] = {
					name = a.name,
					x = data.frames[i].frame.x, y = data.frames[i].frame.y,
					frame_ct = a.to - a.from + 1,
					range = a.from.."-"..a.to,
					row = 1,
					duration = durations
				}
			end
	    end
	end

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