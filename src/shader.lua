local Object = require "libs.classic"
local lg = love.graphics

local Shader = Object:extend()

function Shader:__tostring()
	return "shader"
end

function Shader:new(filepath)
	self.file = filepath
end

function Shader:get()
	return lg.newShader(self.file)
end

return Shader