--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Component = require "src.components.component"

local lvt = require "libs.lovelytiles"

local TiledMap = Component:extend()

function TiledMap:__tostring()
	return "tiledmap"
end

function TiledMap:new(entity, mapdata, startx, starty, w, h, layers, obj)
	TiledMap.super.new(self, entity)

	self.map = lvt.new(mapdata, startx, starty, w, h, layers, obj)

	self.map:foreach("tile", function(map,layer,tile,x,y)
		self.collidables = {}

		if not self.entity.scene.world then
			self.entity.scene:createPhysicWorld()
		end

		local world = self.entity.scene.world
		local px, py = self.position:get()
		local tileset = tile.tileset
		local c = {
			type = "wall",
			solid = true,
			x = (x - 1) * tileset.tilewidth + px,
			y = (y - 1) * tileset.tileheight + py,
			width = tileset.tilewidth,
			height = tileset.tileheight
		}
		if tile.objectGroup and tile.objectGroup.objects then
			for _,o in pairs(tile.objectGroup.objects) do
				if (layer.properties and layer.properties.collidable) or 
					(o.properties and o.properties.collidable) then
					local c1 = copy(c)
					c1.x = c1.x + o.x
					c1.y = c1.y + o.y
					c1.width = o.width
					c1.height = o.height

					self:addCollidable(c1)
				end			
			end
			else
				if (layer.properties and layer.properties.collidable) or
					(tile.properties and tile.properties.collidable) then
				self:addCollidable(c)
			end
		end
	end)

	local scene = self.entity.scene
	local x,y,z = self.position:get()

	local l = 0

	if self.map.backgroundcolor then
		scene:newentity("backgroundcolor",x,y,z-0.1,"backgroundcolor")
			:addComponent("Renderer","rect",self.map.backgroundcolor,"fill",
				self.map.tilewidth * self.map.mapWidth,
				self.map.tileheight * self.map.mapHeight)
	end

	for _,layer in pairs(self.map.layers) do
		if layer.type == "tilelayer" or layer.type == "imagelayer" then
			scene:newentity(layer.name,x,y,z + l,layer.name)
				:addComponent("tiledmaplayer", layer)
			if layer.tiles then
			for x,t in pairs(layer.tiles) do
				for y,tile in pairs(t) do
					if tile.data then
						if type(tile.data.type) == "string" and tile.data.type == "entity" then
							self.entity.scene:initPrefab(
								tile.data.properties.name,
								tile.data.properties.name,
								(x-1)*self.map.tilewidth,(y-1)*self.map.tileheight,z+l,
								tile,
								layer.name
							)
							layer:removeTile(x,y)
							--[[local objData = MapObject:get(tile.data.properties.item)
									if objData then
										local obj = MapObject(self,objData,(x-1)*self.map.tilewidth,
										(y-1)*self.map.tileheight,16,16)
										if objData.image == nil then
											obj.quad = tile.data.quad
											obj.image = tile.tileset.image
										end

										if tile.data.objectGroup then
											local box = tile.data.objectGroup.objects[1]
											obj.x = obj.x + box.x
											obj.y = obj.y + box.y
											obj.sprite_offx = box.x
											obj.sprite_offy = box.y
											obj.width = box.width
											obj.height = box.height
											obj:update_map_item()
										end

										
									end]]
							end
						end
					end
				end
			end
		elseif layer.type == "objectgroup" then
			for _,obj in pairs(layer.objects) do
				if obj.type == "entity" then
					scene:initPrefab(
						obj.name,
						obj.name,
						obj.x+x,obj.y+y,z+l,
						obj,
						layer.name
					)  
				end
			end
		end
		l = l + 1
	end
	
	local tw,th = self.map.tilewidth,self.map.tileheight
	local camera = self.entity.scene.cameras.main

	local screenTileW = game.settings.canvas.width/tw
	local screenTileH = game.settings.canvas.height/th

	local cameraboundx1,cameraboundy1 = (self.map.startx-1)*tw,(self.map.starty-1)*th
	local cameraboundx2,cameraboundy2 = cameraboundx1+(self.map.mapWidth-screenTileW)*tw,cameraboundy1+(self.map.mapHeight-screenTileH)*th

	camera:setWindow(cameraboundx1,cameraboundy1,cameraboundx2,cameraboundy2)
end

function TiledMap:update( dt )
end

function TiledMap:addCollidable(c)
	self.entity.scene.world:add(c,c.x,c.y,c.width,c.height)
	table.insert(self.collidables, c)
end

return TiledMap