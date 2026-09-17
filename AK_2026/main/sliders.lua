-- handles horizontal sliders for volume control in Options. All elements must be called in init
-- can use mouse drag, mouse click in bar, and keyboard input

local states = require "main.states"
local G = {}

local drag = { active = false, target = nil }
local STEP = 0.05
local bars = {}
local focus_order = { "SFX", "music", "master" }
local focus_index = 1
local in_focus = focus_order[focus_index]

local function post_slider_values()
	msg.post("manager:/controller_audio#audio", "slider_moved", {
		master_volume = states.vol_master,
		music_volume = states.vol_music,
		sfx_volume = states.vol_sfx
	})
end

local function update_knob_x_pos(bar, x)
	local bar_parent_pos = gui.get_position(bar.parent)
	local bar_left = bar_parent_pos.x
	local bar_right = bar_left + bar.fullsize.x
	local clamped_x = math.max(bar_left, math.min(x, bar_right))

	local knob_pos = gui.get_position(bar.knob)
	knob_pos.x = clamped_x - bar_left
	gui.set_position(bar.knob, knob_pos)

	local value = (clamped_x - bar_left) / bar.fullsize.x
	gui.set_size(bar.bar, vmath.vector3(bar.fullsize.x * value, bar.fullsize.y, 0))
	gui.set_text(bar.value, math.floor(value * 100) .. "%")
	gui.set_enabled(bar.mute, value == 0)

	if bar == bars.music then
		states.vol_music = value
	elseif bar == bars.SFX then
		states.vol_sfx = value
	elseif bar == bars.master then
		states.vol_master = value
	end

	post_slider_values()
	return value
end

function G.slider_move(action_id, action)
	if action_id == hash("touch") and action.pressed then
		for key, bar in pairs(bars) do
			if gui.pick_node(bar.knob, action.x, action.y) then
				drag.active = true
				drag.target = key
				in_focus = key
				return
			end

			if gui.pick_node(bar.basic_bar, action.x, action.y) then
				drag.active = true
				drag.target = key
				in_focus = key
				update_knob_x_pos(bar, action.x)
				return
			end
		end
	end
end

function G.on_drag(action)
	if drag.active and action.x then
		local bar = bars[drag.target]
		if not bar then return end

		local bar_left = gui.get_position(bar.parent).x
		local bar_right = bar_left + bar.fullsize.x
		local clamped_x = math.max(bar_left, math.min(action.x, bar_right))

		local knob_pos = gui.get_position(bar.knob)
		knob_pos.x = clamped_x - bar_left
		gui.set_position(bar.knob, knob_pos)

		local value = (clamped_x - bar_left) / bar.fullsize.x
		local percent = math.floor(value * 100)
		gui.set_text(bar.value, percent .. "%")
		gui.set_enabled(bar.mute, percent == 0)
		gui.set_size(bar.bar, vmath.vector3(bar.fullsize.x * value, bar.fullsize.y, 0))

		if bar == bars.music then
			states.vol_music = value
		elseif bar == bars.SFX then
			states.vol_sfx = value
		elseif bar == bars.master then
			states.vol_master = value
		end

		post_slider_values()

		if action.released then
			drag.active = false
			drag.target = nil
		end
	end
end

function G.keyboard_adjustment(key, direction)
	local bar = bars[key]
	if not bar then return end

	local current_value = gui.get_position(bar.knob).x / bar.fullsize.x
	local new_value = math.max(0, math.min(1, current_value + STEP * direction))

	if key == "music" then
		states.vol_music = new_value
	elseif key == "SFX" then
		states.vol_sfx = new_value
	elseif key == "master" then
		states.vol_master = new_value
	end

	local pos = gui.get_position(bar.knob)
	pos.x = new_value * bar.fullsize.x
	gui.set_position(bar.knob, pos)

	gui.set_text(bar.value, math.floor(new_value * 100) .. "%")
	gui.set_enabled(bar.mute, new_value == 0)
	gui.set_size(bar.bar, vmath.vector3(bar.fullsize.x * new_value, bar.fullsize.y, 0))

	post_slider_values()
end

function G.keypress(action_id, action)
	if not action.pressed then return end

	if action_id == hash("key_tab") then
		focus_index = (focus_index % #focus_order) + 1
		in_focus = focus_order[focus_index]
	end

	if action_id == hash("key_left") then
		if in_focus == "music" or in_focus == "SFX" or in_focus == "master" then
			G.keyboard_adjustment(in_focus, -1)
		end
	elseif action_id == hash("key_right") then
		if in_focus == "music" or in_focus == "SFX" or in_focus == "master" then
			G.keyboard_adjustment(in_focus, 1)
		end
	elseif action_id == hash("key_a") then
		G.keyboard_adjustment("SFX", -1)
	elseif action_id == hash("key_d") then
		G.keyboard_adjustment("SFX", 1)
	end
end

local function startup_positions()
	gui.set_size(bars.music.bar, vmath.vector3(bars.music.fullsize.x * states.vol_music, bars.music.fullsize.y, 0))
	gui.set_size(bars.SFX.bar, vmath.vector3(bars.SFX.fullsize.x * states.vol_sfx, bars.SFX.fullsize.y, 0))
	gui.set_size(bars.master.bar, vmath.vector3(bars.master.fullsize.x * states.vol_master, bars.master.fullsize.y, 0))

	local pos_mus = gui.get_position(bars.music.knob)
	local pos_sfx = gui.get_position(bars.SFX.knob)
	local pos_master = gui.get_position(bars.master.knob)

	gui.set_position(bars.music.knob, vmath.vector3(bars.music.fullsize.x * states.vol_music, pos_mus.y, 0))
	gui.set_position(bars.SFX.knob, vmath.vector3(bars.SFX.fullsize.x * states.vol_sfx, pos_sfx.y, 0))
	gui.set_position(bars.master.knob, vmath.vector3(bars.master.fullsize.x * states.vol_master, pos_master.y, 0))

	gui.set_text(bars.SFX.value, math.floor(states.vol_sfx * 100) .. "%")
	gui.set_text(bars.music.value, math.floor(states.vol_music * 100) .. "%")
	gui.set_text(bars.master.value, math.floor(states.vol_master * 100) .. "%")

	gui.set_enabled(bars.music.mute, states.vol_music == 0)
	gui.set_enabled(bars.SFX.mute, states.vol_sfx == 0)
	gui.set_enabled(bars.master.mute, states.vol_master == 0)
end

function G.init()
	bars.music = {
		bar = gui.get_node("bar_music"),
		basic_bar = gui.get_node("basic_bar_music"),
		knob = gui.get_node("knob_music"),
		parent = gui.get_node("volume_music"),
		value = gui.get_node("value_music"),
		mute = gui.get_node("mute_music"),
	}
	bars.music.fullsize = gui.get_size(bars.music.bar)

	bars.SFX = {
		bar = gui.get_node("bar_SFX"),
		basic_bar = gui.get_node("basic_bar_SFX"),
		knob = gui.get_node("knob_SFX"),
		parent = gui.get_node("volume_SFX"),
		value = gui.get_node("value_SFX"),
		mute = gui.get_node("mute_SFX"),
	}
	bars.SFX.fullsize = gui.get_size(bars.SFX.bar)

	bars.master = {
		bar = gui.get_node("bar_master"),
		basic_bar = gui.get_node("basic_bar_master"),
		knob = gui.get_node("knob_master"),
		parent = gui.get_node("volume_master"),
		value = gui.get_node("value_master"),
		mute = gui.get_node("mute_master"),
	}
	bars.master.fullsize = gui.get_size(bars.master.bar)

	startup_positions()
end

return G