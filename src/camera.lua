local Entity = require "src.entity"

local lg = love.graphics

local Camera = Entity:extend(Entity)

function Camera:__tostring()
	return "camera"
end

function Camera:new(scene,x,y,w,h,r,sx,sy)
	Camera.super.new(self)

	self.scene = scene

	self.x = x or 0
	self.y = y or 0
	self.width = w
	self.height = h

	self.alpha = 1

	self.r = r or 0

	self.position.scalex = sx or 1
	self.position.scaley = sy or self.position.scalex

	self.zoom = 0

	self.window = {x1=nil,y1=nil,x2=nil,y2=nil}

	self.following = nil
	self.smoothfactor = 0.12

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
    --lg.scale(self.position.scalex,self.position.scaley)
    lg.translate(-self.x - self.zoom, -self.y - self.zoom)
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
	
	lg.draw(self.canvas,x,y,0,self.position.scalex,self.position.scaley)
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
	local x, y = self.following.components.position.x, self.following.components.position.y
	self:setPosition(
		lerp(self.x, x - self.width / 2, l),
		lerp(self.y, y - self.height / 2, l)
	)
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
	return love.mouse.getX() / self.position.scalex + self.x - self.position.x / self.position.scalex,
		   love.mouse.getY() / self.position.scaley + self.y - self.position.y / self.position.scaley
end

function Camera:toScreen(x,y)
	return (x - self.x) * self.scalex , (y - self.y) * self.scaley
end

return Camera