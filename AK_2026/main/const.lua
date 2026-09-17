-- local const = require "main.const"
local S = require "main.states"


local C = {}
-- sizes, clamps, safe spaces
C.screenwidth = 0
C.screenheight = 0
C.screenwidth_half = 0
C.screenheight_half = 0

C.screen_min_x = 0
C.screen_max_x = 0
C.screen_min_y = 0
C.screen_max_y = 0

function C.set_screen_size(width, height)
	C.screenwidth = width
	C.screenheight = height

	C.screenwidth_half = C.screenwidth / 2
	C.screenheight_half = C.screenheight / 2

	C.screen_min_x = 0
	C.screen_max_x = C.screenwidth
	C.screen_min_y = 0
	C.screen_max_y = C.screenheight	
end

return C