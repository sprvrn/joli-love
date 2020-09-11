local Component = require "src.components.component"

local Map = require "libs.tiledmap"

local TiledMap = Component:extend(Component)

function TiledMap:__tostring()
	return "tiledmap"
end

function TiledMap:new(entity, mapdata, startx, starty, w, h, layers)
	TiledMap.super.new(self, entity)

	self.data = Map(mapdata, startx, starty, w, h, layers)

	local scene = self.entity.scene
	local x,y,z = self.position:get()

	local l = 0

	for name,layer in pairs(self.data.layers) do
		if layer.type == "tilelayer" then
			local b = 1
		    for _,batch in pairs(layer.batches) do
				scene:newentity(layer.name .. "_" .. tostring(b),x,y,z + l)
					:addComponent("renderer","batch",batch)
				b = b + 1
			end
		elseif layer.type == "objectgroup" then
		    for _,obj in pairs(layer.objects) do
		    	self.entity.scene:initPrefab(game.assets.prefabs[obj.name],obj.name,obj.x,obj.y,z+l)
			end
		end
		l = l + 1
	end

	self:initCollidables()

	local tw,th = self.data.tilewidth,self.data.tileheight
	local camera = self.entity.scene.cameras.main

	local screenTileW = game.settings.canvas.width/tw
	local screenTileH = game.settings.canvas.height/th

	local cameraboundx1,cameraboundy1 = (self.data.startx-1)*tw,(self.data.starty-1)*th
	local cameraboundx2,cameraboundy2 = 
		cameraboundx1+(self.data.mapWidth-screenTileW)*tw,cameraboundy1+(self.data.mapHeight-screenTileH)*th

	camera:setWindow(cameraboundx1,cameraboundy1,cameraboundx2,cameraboundy2)
end

function TiledMap:update( dt )
	if self.data then
		self.data:update(dt)
	end
end

function TiledMap:initCollidables()
	self.collidables = {}
	
	if not self.entity.scene.world then
	    self.entity.scene:createPhysicWorld()
	end

	local world = self.entity.scene.world

	for _,layer in pairs(self.data.layers) do
		if layer.properties.collidable then
		    for x,t in pairs(layer.tiles) do
	    		for y,tile in pairs(t) do
		    		if tile.tileset ~= nil then
		    			local tileset = tile.tileset
		    			local c = {
		    				type = "wall",
		    				solid = true,
		    				x = (x - 1) * tileset.tilewidth,
		    				y = (y - 1) * tileset.tileheight,
		    				width = tileset.tilewidth,
		    				height = tileset.tileheight
		    			}
		    			if tile.data.objectGroup and tile.data.objectGroup.objects then
		    			    local o = tile.data.objectGroup.objects[1]
		    			    c.x = c.x + o.x
		    			    c.y = c.y + o.y
		    			    c.width = o.width
		    			    c.height = o.height
		    			end
		    		    world:add(c,c.x,c.y,c.width,c.height)
		    		    table.insert(self.collidables, c)
		    		end
		    	end
		    end
		end
	end
end


function TiledMap:initEntities(playerEnt)
	for _,layer in pairs(self.layers) do
		if layer.type == "objectgroup" then
			for _,obj in pairs(layer.objects) do

			end
		end
		--[[elseif layer.type == "tilelayer" then
		    for x,t in pairs(layer.tiles) do
	    		for y,tile in pairs(t) do
	    			if tile.data then
	    				if tile.data.properties then
	    				    local objData = MapObject:get(tile.data.properties.item)
		    			    if objData then
		    			        local obj = MapObject(self,objData,(x-1)*self.map.tilewidth,(y-1)*self.map.tileheight,16,16)
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

		    			        layer:removeTile(x,y)
		    			    end
	    				end
	    			end
	    		end
	    	end
		end]]
	end
end

function TiledMap:debugLayout(ui)
	ui:layoutRow('dynamic', 20, 1)

end

return TiledMap