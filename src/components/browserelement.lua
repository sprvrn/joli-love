local Component = require "src.components.component"

local BrowserElement = Component:extend(Component)

function BrowserElement:__tostring()
	return "browserelement"
end

function BrowserElement:new(entity,data,browser)
	BrowserElement.super.new(self, entity)

	self.browser = browser

	self.label = data.label
	self.nexts = {}
	self.onActivation = data.method
	self.activationKey = data.activationKey
	self.width = data.width or 64
	self.height = data.height or 16

	self.style = data.style
	self.hoverstyle = data.hoverstyle
	self.disablestyle = data.disablestyle

	if data.sprite then
	    self.entity:addComponent("Renderer","sprite",data.sprite)
	elseif type(self.label) == "string" then
		self.entity:addComponent("Renderer","text",self.label,data.style,data.width,data.align or "left")
	end

	self.entity:addComponent("SoundSet")
	self.sounds = self.entity:getComponent("SoundSet")

	if data.navsound then
	    self.sounds:addSource("nav", data.navsound)
	end
	if data.actsound then
	    self.sounds:addSource("act", data.actsound)
	end
end

function BrowserElement:add(key, e)
	local n = {key = key, element = e}
	table.insert(self.nexts, n)
end

function BrowserElement:updateElement(dt,br)
	for i=1,#self.nexts do
		local n = self.nexts[i]
		if game.input:pressed(n.key) then
			if n.element then
				br:setCurrent(br.list[n.element])
				break
			end
		end
	end
	if self.activationKey and game.input:pressed(self.activationKey) then
	    if type(self.onActivation) == "function" then
	    	if self.entity:getComponent("SoundSet") then
				if self.entity:getComponent("SoundSet").sources.act then
				    self.entity:getComponent("SoundSet").sources.act:play()
				end
			end
	        self.onActivation(self)
	    end
	end
end

function BrowserElement:draw()
end

return BrowserElement