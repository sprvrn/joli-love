--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"

local File = Object:extend()

local lf = love.filesystem

function File:new()

end

function File:write(filename, data)
	lf.write(filename,TSerial.pack(data, nil, false))
end

function File:append(filename, data)
	local file = love.filesystem.read(filename)

	local savedData = {}

	if file then
	    savedData = TSerial.unpack(file)
	end

	table.insert(savedData, data)

	self:write(filename, savedData)
end

function File:load(filename)
	if lf.getInfo(filename) then
		local data = TSerial.unpack(lf.read(filename))
		return data
	end
end

return File


	--[[load = function(filename)
		game.filename = filename or "1"
		if love.filesystem.getInfo(game.filename..".sav") then
			local savefile = TSerial.unpack(love.filesystem.read(game.filename..".sav"))

			-- load tables
		    --game.character = savefile.character
		end
	end]]
