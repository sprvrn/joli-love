--[[
joli-love
small framework for love2d
MIT License (see licence file)
]]

local Object = require "libs.classic"
local Scene = require "src.scene"
local Sprite = require "src.sprite"
local Shader = require "src.shader"

require "libs.TSerial"
require "libs.utils"
local cargo = require("libs.cargo")
local baton = require ("libs.baton")
tick = require ('libs.tick')
Color = require ("libs.hex2color")

local Game = Object:extend()

local lg,lf = love.graphics,love.filesystem

function Game:new(version)
	self.joliversion = version
	lg.setDefaultFilter("nearest", "nearest")

	self:loadSettings()

	self.t = 0

	self.assets = cargo.init({
		dir = 'assets',
		loaders = {
			png = Sprite,
			glsl = Shader
		}
	})

	self.statetree = self:buildStateTree(require('assets.states.statetree'))

	self.components = cargo.init('src/components')
	self.assetscomponents = cargo.init('assets/components')

	self.file = require("src.file")(self.assets.save)

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
		local font = nil
		if style.font and self.assets.fonts[style.font] then
		    font = self.assets.fonts[style.font](style.size or 16)
		end
		self.assets.fonts[name] = {}

		for k,v in pairs(style) do
			self.assets.fonts[name][k] = v
		end

		self.assets.fonts[name].font = font
		self.assets.fonts[name].color = style.color or {1,1,1,1}
	end

	self.defaultfont = love.graphics.getFont()
	--lg.setFont(self.assets.fonts.main.font)

	self.scenes = {}

	self.filename = "1"

	tick.framerate = self.settings.maxfps

	if self.assets.inputs then
	    self.input = baton.new(self.assets.inputs)
	end

	require ("src.love2dcalls")()

	self.displaydebug = false
	self.debug = require("src.debug")()
	if self.settings.debug then
	    self.gui = require("src.gui")()
	end

	Icon = require("libs.slog-icon")
	if self.assets.sprites[self.settings.iconimg] then
	    Icon.configure(self.settings.iconsize, self.assets.sprites[self.settings.iconimg].image)
	end

	self:setWindow()

	self.viewx = 0
	self.viewy = 0
end

function Game:getComponent(name)
	return self.components[name] or self.assetscomponents[name]
end

function Game:newscene(name, ...)
	local newScene = Scene(name, ...)
	self.scenes[name] = newScene
	self[name] = newScene
	return newScene
end

function Game:destroyscene(name)
	if self.scenes[name] then
	    self.scenes[name] = nil
	    self[name] = nil
	else
	    print("Warning: attempt to destroy scene <"..name..">, but it does not exists.")
	end
end

function Game:loadSettings()
	if lf.getInfo("settings.sav") then
		self.settings = TSerial.unpack(lf.read("settings.sav"))
	else
	    self.settings = require("assets.settings")
	    self.settings.window.width = self.settings.canvas.width * self.settings.canvas.scale
		self.settings.window.height = self.settings.canvas.height * self.settings.canvas.scale
	end

	love.filesystem.setIdentity(self.settings.identity)
end

function Game:writeSettings(newW,newH)
	self.settings.window.width = newW
	self.settings.window.height = newH
	lf.write("settings.sav",TSerial.pack(self.settings))
end

function Game:setWindow()
	local settings = copy(self.settings).window
	settings.width = nil
	settings.height = nil
	settings.title = nil
	settings.icon = nil
	love.window.setMode(
		self.settings.window.width or lg.getWidth(),
		self.settings.window.height or lg.getHeight(),
		settings)
	love.window.setTitle(self.settings.window.title)
	love.window.setIcon(love.image.newImageData(self.settings.window.icon))
end

function Game:buildStateTree(state,parent)
	local r = {}
	if type(state) == "table" then
		for name,s in pairs(state) do
			if self.assets.states[name] then
			    r[name] = self.assets.states[name]()
				r[name].name = name
				r[name].parent = parent
				r[name].pause = false
				r[name].hide = false
				r[name].childs = self:buildStateTree(s,r[name])
			else
				print("Warning: state "..name.." in state tree not found.")
			end
		end
	end
	return r
end

function Game:state()
	return self.current_state
end

function Game:states()
	return self.statetree
end

function Game:stateUpdate(state,dt)
	--if state.methods.update then
		if not state.pause then
		    state:update(dt)
		end
	    
	    if state.parent and not state.parent.skipnext then
	        self:stateUpdate(state.parent,dt)
	    end
	    if state.parent then
	    	state.parent.skipnext = false
	    end
	--end
end

function Game:stateDraw(state,t)
	--if state.methods.draw then
		if not state.hide then
			table.insert(t, state)
		end
	    
	    if state.parent then
	        t = self:stateDraw(state.parent,t)
	    end
	--end
	return t
end

function Game:init(statename)
	local f = function()
		self.splash = nil
		if not statename then
		    for name,state in pairs(self.statetree) do
				self:stateActivation(name)
				break
			end
		end
	end
	if self.settings.lovesplash then
	    self.splash = require("libs.o-ten-one")(self.settings.lovesplash)
	    self.splash.onDone = f
	else
	    f()
	end
	
end

function Game:stateActivation(name, ...)
	assert(type(name)=="string")
	if not self.current_state then
	    self.current_state = self.statetree[name]
	    self.current_state:onEnter(...)
	else
	    if self.current_state.childs[name] then
	        self.current_state = self.current_state.childs[name]
	        self.current_state:onEnter(...)
	    else
	    	if self.current_state.parent and self.current_state.parent.childs[name] then
	    		self.current_state:onExit()
	    		self.current_state = self.current_state.parent.childs[name]
	    		self.current_state:onEnter(...)
	    	elseif self:states()[name] then
	    	    self.current_state:onExit()
	    	    self.current_state = self:states()[name]
	    	    self.current_state:onEnter(...)
	    	end
	    end
	end
end

function Game:stateQuit()
	self.current_state:onExit()

	if self.current_state.parent then
		self.current_state = self.current_state.parent
		self.current_state.skipnext = true
	else
	    self.current_state = nil
	end
end

function Game:update(dt)
	self.input:update(dt)

	if self.splash then
	    self.splash:update(dt/2)
	    return
	end
	
	if self.settings.debug and self.input:pressed("displaydebug") then
	    self.displaydebug = not self.displaydebug
	end

	if self.input:pressed("screenshot") then
	    lg.captureScreenshot(os.time() .. ".png")
	end

	local state = self:state()
	if state then
		self:stateUpdate(state,dt)
	end

	self.debug:update(dt)

	if self.gui and self.displaydebug then
	    self.gui:update(dt)
	end

	self.t = self.t + dt
end

function Game:draw()
	if self.splash then
	    self.splash:draw()
	    return
	end
	local state = self:state()
	if state then
		local draws = self:stateDraw(state, {})
		for i=#draws,1,-1 do
			draws[i]:draw()
		end
	else
		lg.setBackgroundColor(0.3, 0.3, 0.3, 1)
	    lg.print("joli-love ("..require("src.joli")._VERSION..") framework for love2d (no game detected)",10,10)
	end

	if self.displaydebug then
	   self.gui:draw()
	   self.debug:draw()
	end
end

return Game