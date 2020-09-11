local Object = require "libs.classic"

local SoundSource = Object:extend(Object)

function SoundSource:__tostring()
	return "soundsource"
end

function SoundSource:new(arg,set)
	self.layers = {}
	self.set = set

	if type(arg) == "table" then
	    for name,layer in pairs(arg) do
	    	self.layers[name] = layer
	    end
	end

	self.layers = {arg}

	self.maxvolume = 1
	self.volume = self.maxvolume
end

function SoundSource:update( dt )
	for _,layer in pairs(self.layers) do
		layer:setVolume(self.volume)
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

function SoundSource:play(loop,dur)
	loop = loop or false
	if dur then
		self:fadein(dur)
	end
	for _,layer in pairs(self.layers) do
		layer:setLooping(loop)
		layer:play()	
	end
end

function SoundSource:stop(dur)
	if dur then
	    self:fadeout(dur)
	end
	for _,layer in pairs(self.layers) do
		layer:stop()
	end
end

function SoundSource:pause(dur)
	local f = function()
		for _,layer in pairs(self.layers) do
			layer:pause()
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
	for _,layer in pairs(self.layers) do
		if not layer:isPlaying() and layer:tell() ~= 0.0 then
			if dur then
			    self:fadein(dur)
			end
		    layer:play()
		end
	end
end

return SoundSource