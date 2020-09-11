return {
	write = function()
		local savefile = {}

		-- write different tables here
		--savefile["character"] = game.character

		-- end write tables

		love.filesystem.write(game.filename..".sav",TSerial.pack(savefile))
	end,

	load = function(filename)
		game.filename = filename or "1"
		if love.filesystem.getInfo(game.filename..".sav") then
			local savefile = TSerial.unpack(love.filesystem.read(game.filename..".sav"))

			-- load tables
		    --game.character = savefile.character
		end
	end
}