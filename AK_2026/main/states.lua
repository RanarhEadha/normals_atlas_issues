-- local S = require "main.states"

local S = {}
-- game states
S.paused = false
S.game_running = false



-- mapped keys
S.left_keys = {
	[hash("key_left")] = true,
	[hash("key_a")] = true,
	[hash("gamepad_lpad_left")] = true,

}
S.right_keys = {
	[hash("key_right")] = true,
	[hash("key_d")] = true,
	[hash("gamepad_lpad_right")] = true,
}
S.jump_keys = {
	[hash("key_space")] = true,
	[hash("key_w")] = true,
	[hash("key_up")] = true,
	[hash("gamepad_rpad_up")] = true,
}
S.pause_keys = {
	[hash("key_escape")] = true,
	[hash("key_p")] = true,
	[hash("key_pause")] = true,	
	[hash("gamepad_start")] = true,
}
S.down_keys = {
	[hash("key_down")] = true,
	[hash("key_s")] = true,
	[hash("gamepad_rpad_down")] = true,	
}
	

return S