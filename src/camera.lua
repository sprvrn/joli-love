--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Entity = require "src.entity"

local lg, lm = love.graphics, love.mouse

local Camera = Entity:extend(Entity)

function Camera:__tostring()
	return "camera"
end

function Camera:new(scene,name,x,y,w,h,r,sx,sy)
	Camera.super.new(self,name)

	self.name = name

	self.scene = scene

	self.x = x or 0
	self.y = y or 0
	self.width = w
	self.height = h

	self.alpha = 1

	self.r = r or 0

	self.position.scalex = sx or 1
	self.position.scaley = sy or self.position.scalex

	self.zoom = 1

	self.window = {x1=nil,y1=nil,x2=nil,y2=nil}

	self.following = nil
	self.smoothfactor = 0.05

	self.canvas = lg.newCanvas(self.width,self.height)
end

function Camera:set()
	if self.scene.hide then
		return
	end
	lg.setCanvas(self.canvas)
	lg.clear()

	lg.push()
	lg.rotate(-self.r)
	lg.scale(self.zoom,self.zoom)
	lg.translate(-self.x, -self.y)
end

function Camera:unset()
	if self.scene.hide then
		return
	end
	lg.pop()
end

function Camera:draw()
	if self.scene.hide then
		return
	end
	lg.setCanvas()

	lg.setColor(1, 1, 1, self.alpha)

	if blendmode then
		lg.setBlendMode('alpha','premultiplied')
	end

	local x, y = self.position:get()
	
	lg.draw(self.canvas,x+game.viewx,y+game.viewy,0,self.position.scalex,self.position.scaley)
	lg.setBlendMode("alpha")
	lg.setColor(1,1,1,1)
end

function Camera:update( dt )
	Camera.super.update(self,dt)

	self:follow(self.smoothfactor)
end

function Camera:setWindow(x1,y1,x2,y2)
	self.window = {x1=x1,y1=y1,x2=x2,y2=y2}
end

function Camera:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y

	if self.window.x1 and self.x<self.window.x1 then
		self.x=self.window.x1
	end
	if self.window.x2 and self.x>self.window.x2 then
		self.x=self.window.x2
	end
	if self.window.y1 and self.y<self.window.y1 then
		self.y=self.window.y1
	end
	if self.window.y2 and self.y>self.window.y2 then
		self.y=self.window.y2
	end
end

function Camera:follow(l)
	if not self.following then
		return
	end
	l = l or 1
	local x, y = self.following.position.x, self.following.position.y
	self:setPosition(lerp(self.x, x - self.width*0.5, l),lerp(self.y, y - self.height*0.5, l))
end

function Camera:move(dx, dy)
	self:setPosition(self.x + (dx or 0),self.y + (dy or 0))
end

function Camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function Camera:fadein(duration)
	self.alpha = 0
	self:tween(duration,{alpha = 1})
end

function Camera:fadeout(duration)
	self.alpha = 1
	self:tween(duration,{alpha = 0})
end

function Camera:mousePosition()
	local mx,my = lm.getX()-game.viewx,lm.getY()-game.viewy

	if mx > self.width * self.position.scalex or
		 my > self.height * self.position.scaley or
		 mx < 0 or my < 0 then
		return nil, nil
	end

	return ((mx / self.position.scalex + self.x - self.position.x / self.position.scalex)),
		   ((my / self.position.scaley + self.y - self.position.y / self.position.scaley))
end

function Camera:toScreen(x,y)
	return (x - self.x) * self.scalex , (y - self.y) * self.scaley
end

function Camera:resizeToWindow(w,h)
	w = w or lg.getWidth()
	h = h or lg.getHeight()
	local sx, sy = w / game.settings.canvas.width, h / game.settings.canvas.height
	if sx < sy then
		sy = sx
	else
		sx = sy
	end
	self.position.scalex = sx
	self.position.scaley = sy

	game.viewx = (w - (sx * game.settings.canvas.width)) / 2
	game.viewy = (h - (sy * game.settings.canvas.height)) / 2
end

function Camera:debugLayout(ui)
	if ui:treePush('node',self.name) then
		ui:layoutRow('dynamic', 20, 2)
		self.position.x = ui:property("position x", -10000000, self.position.x, 10000000, 1, 1)
		self.position.y = ui:property("position y", -10000000, self.position.y, 10000000, 1, 1)
		ui:layoutRow('dynamic', 20, 2)
		self.x = ui:property("x", -10000000, self.x, 10000000, 1, 1)
		self.y = ui:property("y", -10000000, self.y, 10000000, 1, 1)
		if game.settings.mouse then
			ui:layoutRow('dynamic', 20, 1)
			ui:label("Mouse position")
			ui:layoutRow('dynamic', 20, 2)
			local mx,my = self:mousePosition()
			if mx and my then
				ui:label(mx)
				ui:label(my)
			else
				ui:label("nil")
				ui:label("nil")
			end
			
		end
		ui:layoutRow('dynamic', 20, 1)
		ui:label("Following : "..tostring(self.following))
		ui:layoutRow('dynamic', 20, 2)
		self.width = ui:property("Width", 50, self.width, 40000, 1, 1)
		self.height = ui:property("Height", 50, self.height, 40000, 1, 1)
		ui:layoutRow('dynamic', 20, 2)
		self.position.scalex = ui:property("Scale x", 1, self.position.scalex, 50, 1, 1)
		self.position.scaley = ui:property("Scale y", 1, self.position.scaley, 50, 1, 1)
		ui:layoutRow('dynamic', 20, 1)
		self.alpha = ui:property("Alpha", 0, self.alpha, 1, 0.01, 0.01)
		ui:layoutRow('dynamic', 20, 1)
		self.zoom = ui:property("Zoom", 0, self.zoom, 1000000, 0.1, 0.1)
		ui:layoutRow('dynamic', 20, 1)
		self.smoothfactor = ui:property("Smooth", 0, self.smoothfactor, 1, 0.01, 0.01)
		ui:treePop()
	end
end

return Camera