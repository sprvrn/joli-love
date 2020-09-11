return {
	example = function(scene,name,x,y,z)
		local entity = scene:newentity("example",x,y,z)
			:addComponent("component",arg1,arg2)
	end
}