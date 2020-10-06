--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local ParticleEmiter = Component:extend()

function ParticleEmiter:__tostring()
	return "particleemiter"
end

function ParticleEmiter:new(entity,system,mode,delay)
	ParticleEmiter.super.new(self, entity)

	self.systems = {}
	if system then
	    self:addSystem(system, mode, delay)
	end
end

function ParticleEmiter:addSystem(system,mode,delay)
	mode = mode or "every"
	delay = delay or 1

	local timer = nil

	local emit = function()
		local x,y,z = self.position:get()
		self.entity.scene:particle(system,x,y,z)
	end

	if mode == "every" then
	    timer = self.entity:cron(mode,delay,emit)
	elseif mode == "once" then
	    emit()
	end

	local sys = {system=system,mode=mode,delay=delay,timer=timer}
	table.insert(self.systems, {system=system,mode=mode,delay=delay})
end

return ParticleEmiter