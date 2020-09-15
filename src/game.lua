local Object = require "libs.classic"
local Scene = require "src.scene"
local Sprite = require "src.sprite"

require "libs.TSerial"
require "libs.misc"

local Game = Object:extend(Object)

local lg,lf = love.graphics,love.filesystem

local eventcall = {"keypressed","keyreleased","mousepressed","mousereleased","mousemoved","textinput","wheelmoved"}

function Game:new()
	lg.setDefaultFilter("nearest", "nearest")

	self.save = require "src.savegame"

	self:loadSettings()

	self.t = 0

	self.game_states = require("libs.cargo").init('assets/states')

	self.assets = require("libs.cargo").init({
		dir = 'assets',
		loaders = {
			png = Sprite.load
		}
	})

	self.components = require("libs.cargo").init('src/components')
	self.assetscomponents = require("libs.cargo").init('assets/components')

	local prefabs = {}
	for _,p in pairs(self.assets.prefabs()) do
		if type(p) == "table" then
		    for name,method in pairs(p) do
		    	if type(method) == "function" then
		    		if prefabs[name] then
		    		    print("Warning, prefabs loading : " .. name .. " already exists.")
		    		end
		    	    prefabs[name] = method
		    	end
		    end
		end
	end
	self.assets.prefabs = prefabs

	for name,style in pairs(require("assets.fonts.style")) do
		self.assets.fonts[name] = {
			font = self.assets.fonts[style.font](style.size),
			color = style.color
		}
	end

	self.defaultfont = love.graphics.getFont()
	lg.setFont(self.assets.fonts.main.font)

	self.scenes = {}

	self.filename = "1"

	self.input = self.assets.inputs

	self.displaydebug = false
	self.debug = require("src.debug")()
	self.gui = require("src.gui")()

	for _,name in pairs(eventcall) do
		love[name] = function(...)
			self.gui.ui[name](self.gui.ui,...)
		end
	end

	self:setWindow()
end

function Game:getComponent(name)
	return self.components[name] or self.assetscomponents[name]
end

function Game:newscene(name)
	local newScene = Scene(name)
	self.scenes[name] = newScene
	self[name] = newScene
	return newScene
end

function Game:loadSettings()
	if lf.getInfo("settings.sav") then
		self.settings = TSerial.unpack(lf.read("settings.sav"))
	else
	    self.settings = require("assets.settings")
	    self.settings = self:getSettings()
	end
end

function Game:writeSettings(newW,newH)
	self.settings.window.width = newW
	self.settings.window.height = newH
	lf.write("settings.sav",TSerial.pack(self:getSettings()))
end

function Game:getSettings()
	local settings = self.settings

	if not settings.window then
		settings.window = {}
	    settings.window.width = settings.canvas.width * settings.canvas.scale
	    settings.window.height = settings.canvas.height * settings.canvas.scale
	    settings.window.fullscreen = love.window.getFullscreen()
	end

	return settings
end

function Game:setWindow()
	love.window.setMode(
		self.settings.window.width or lg.getWidth(),
		self.settings.window.height or lg.getHeight(),
		{resizable=true})
	love.window.setFullscreen(self.settings.window.fullscreen)
end

function Game:change_state(n)
	if self.game_states[n] then
		if self.current_state then
			if self:state().on_exit then
				self:state().on_exit()
			end
		end
		self.current_state=n
		if self.game_states[n].on_enter then
			self.game_states[n].on_enter()
		end
	else
	    print("state",n,"not found")
	end
end

function Game:state()
	if self.current_state~=nil then
		return self.game_states[self.current_state]
	end 
end

function Game:update(dt)
	self.input:update(dt)

	self.gui:update(dt)

	if self.input:pressed("displaydebug") then
	    self.displaydebug = not self.displaydebug
	end

	if self.input:pressed("screenshot") then
	    lg.captureScreenshot(os.time() .. ".png")
	end

	local state = self:state()
	if state then
		if state.update then
		    state.update(dt)
		end
	end

	self.debug:update(dt)

	self.t = self.t + dt
end

function Game:draw()
	local state = self:state()
	if state then
		if state.draw then
		    state.draw()
		end
	end

	if self.displaydebug then
	   self.gui:draw()
	   self.debug:draw()
	end
end

return Game