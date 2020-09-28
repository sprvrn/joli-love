--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local SoundSource = Object:extend()

function SoundSource:__tostring()
	return "soundsource"
end

function SoundSource:new(source,set)
	self.set = set

	self.sources = {}

	if type(source) == "table" then
	    --self.sources = source
	    for i=1,#source do
	    	table.insert(self.sources, source[i]:clone())
	    end
	else
	    self.sources[1] = source:clone()
	end

	self.maxvolume = 1
	self.volume = self.maxvolume
end

function SoundSource:update( dt )
	for _,s in pairs(self.sources) do
		s:setVolume(self.volume)
	end
end

function SoundSource:fadein(dur)
	self.volume = 0
	self.set.entity:tween(dur,{volume = self.maxvolume},'linear',self)
end

function SoundSource:fadeout(dur)
	self.volume = self.maxvolume
	self.set.entity:tween(dur,{volume = 0},'linear',self)
end

function SoundSource:play(loop,intro,fadedur)
	loop = loop or false
	if type(fadedur) == "number" then
		self:fadein(fadedur)
	end
	if #self.sources > 1 then
	    if intro then
	        self.sources[1]:setLooping(false)
		    self.sources[1]:play()
		    self.set.entity:cron("after",self.sources[1]:getDuration("seconds"),
		    	function()
		    		self.sources[1]:stop()
		    		self.sources[2]:setLooping(loop)
		    		self.sources[2]:play()
		    	end)
	    else
	        self.sources[2]:setLooping(loop)
	    	self.sources[2]:play()
	    end
	elseif #self.sources == 1 then
	    self.sources[1]:setLooping(loop)
	    self.sources[1]:play()
	end
end

function SoundSource:stop(dur)
	if dur then
	    self:fadeout(dur)
	end
	for _,s in pairs(self.sources) do
		s:stop()
	end
end

function SoundSource:pause(dur)
	local f = function()
		for _,s in pairs(self.sources) do
			s:pause()
		end
	end

	f()

	if dur then
	    --self:fadeout(dur)
	    --self.set.entity:cron("after",dur,f)
	else
	    f()
	end
	
end

function SoundSource:resume(dur)
	for _,s in pairs(self.sources) do
		if not s:isPlaying() and s:tell() ~= 0.0 then
			if dur then
			    self:fadein(dur)
			end
		    s:play()
		end
	end
end

return SoundSource