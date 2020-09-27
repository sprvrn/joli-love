local nuklear = require "nuklear"
local Object = require "libs.classic"

local GUI = Object:extend()

function GUI:new()
	self.ui = nuklear.newUI()
end

function displayfield(ui,k,v)
	if k=="entity" or k== "position" or k=="scene" then
	    return
	end
	if type(v) == "table" then
	    if ui:treePush('node',k) then
	        for k,v in pairs(v) do
	        	ui:layoutRow('dynamic', 10, 1)
				ui:label(k.." : "..tostring(v))
	        end
	        ui:treePop()
	    end
	else
		ui:layoutRow('dynamic', 10, 1)
		ui:label(k.." : "..tostring(v))
	end
end

function GUI:update(dt)
	local ui = self.ui
	
	ui:frameBegin()
	if ui:windowBegin('Debug', 200, 0, 400, 800, 'title', 'movable', 'scrollbar') then
		--ui:groupBegin("debugwindow",'title','border') 
			ui:layoutRow('dynamic', 20, 1)
			ui:label('Fps : '..tostring(love.timer.getFPS()))
			ui:layoutRow('dynamic', 20, 1)
			ui:label("State : "..tostring(game.current_state.name))
			
			for _,scene in pairs(game.scenes) do
				if ui:treePush('tab',scene.name) then
					ui:layoutRow('dynamic', 20, 2)	
					scene.pause = ui:checkbox("Pause", scene.pause)
					scene.hide = ui:checkbox("Hide", scene.hide)
					for name,c in pairs(scene.cameras) do
						c:debugLayout(ui)
					end
					ui:label("Entity ( #"..tostring(#scene.entities)..")")
					for _,e in pairs(scene.entities) do
						if ui:treePush('node',e.name) then
							ui:layoutRow('dynamic', 15, 1)
							ui:label("tag : " .. tostring(e.tag))
							ui:layoutRow('dynamic', 20, 2)
							e.pause = ui:checkbox("Pause", e.pause)
							e.hide = ui:checkbox("Hide", e.hide)
							--ui:layoutRow('dynamic', 20, 2)
							--ui:label("cron # " .. tostring(#e.crons))
							--ui:label("tween # " .. tostring(#e.tweens))
							--ui:layoutRow('dynamic', 20, 1)
							for _,c in pairs(e.components) do
								ui:layoutRow('dynamic', 175, 1)
								if ui:groupBegin(tostring(c), 'title','border','scrollbar') then
									c:debugLayout(ui)
									ui:groupEnd()
								end
								
							end
							ui:treePop()
						end
					end
					ui:treePop()
				end
			end
			--ui:groupEnd()
		--end
	end



	ui:windowEnd()
	ui:frameEnd()
end


function GUI:draw()
	self.ui:draw()
end

return GUI