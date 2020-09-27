return {
	controls = {
		leftclick = {'mouse:1'},
		rightclick = {'mouse:2'},
		middleclick = {'mouse:3'},

		left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
		right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
		up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
		down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},

		pause = {'key:p','button:start','key:space'},

		displaydebug = {'key:f1'},
		screenshot = {'key:f12'},
		toggle = {'key:t'},

		interact = {'key:return','button:start'},
		
		screenshot = {"key:f12"}
	},
	pairs = {
		move = {'left','right','up','down'},
	},
	joystick = love.joystick.getJoysticks()[1]
}
