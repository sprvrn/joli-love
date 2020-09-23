local Component = require "src.components.component"

local SoundSource = require "src.soundsource"

local SoundSet = Component:extend(Component)

function SoundSet:__tostring()
	return "soundset"
end

function SoundSet:new(entity)
	SoundSet.super.new(self, entity)

	self.sources = {}
end

function SoundSet:addSource(name, sounds, play, loop, intro)
	self.sources[name] = SoundSource(sounds,self)
	if play then
	    self.sources[name]:play(loop, intro)
	end

	return self.sources[name]
end

function SoundSet:update( dt )
	for _,source in pairs(self.sources) do
		source:update(dt)
	end
end

function SoundSet:pause(dur)
	for _,source in pairs(self.sources) do
		source:pause(dur)
	end
end

function SoundSet:resume(dur)
	for _,source in pairs(self.sources) do
		source:resume(dur)
	end
end

return SoundSet