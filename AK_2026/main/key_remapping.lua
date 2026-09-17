local sliders = require "main.sliders"
local states = require "main.states"
local save = require "main.save"
local G = require "main.globals"
local U = require "main.utilities"

local M = {}

-- list of buttons displaying the activity states of editable fields, here: left and right controls and pause
local frame_left
local frame_right
local frame_pause

local action_id_to_label = {
	-- Keyboard
	[hash("key_space")] = "space",
	[hash("key_exclamationmark")] = "!",
	[hash("key_doublequote")] = "\"",
	[hash("key_hash")] = "#",
	[hash("key_dollarsign")] = "$",
	[hash("key_ampersand")] = "&",
	[hash("key_singlequote")] = "'",
	[hash("key_lparen")] = "(",
	[hash("key_rparen")] = ")",
	[hash("key_asterisk")] = "*",
	[hash("key_plus")] = "+",
	[hash("key_comma")] = ",",
	[hash("key_minus")] = "-",
	[hash("key_period")] = ".",
	[hash("key_slash")] = "/",

	[hash("key_0")] = "0",
	[hash("key_1")] = "1",
	[hash("key_2")] = "2",
	[hash("key_3")] = "3",
	[hash("key_4")] = "4",
	[hash("key_5")] = "5",
	[hash("key_6")] = "6",
	[hash("key_7")] = "7",
	[hash("key_8")] = "8",
	[hash("key_9")] = "9",

	[hash("key_colon")] = ":",
	[hash("key_semicolon")] = ";",
	[hash("key_lessthan")] = "<",
	[hash("key_equals")] = "=",
	[hash("key_greaterthan")] = ">",
	[hash("key_questionmark")] = "?",
	[hash("key_at")] = "@",

	[hash("key_a")] = "a",
	[hash("key_b")] = "b",
	[hash("key_c")] = "c",
	[hash("key_d")] = "d",
	[hash("key_e")] = "e",
	[hash("key_f")] = "f",
	[hash("key_g")] = "g",
	[hash("key_h")] = "h",
	[hash("key_i")] = "i",
	[hash("key_j")] = "j",
	[hash("key_k")] = "k",
	[hash("key_l")] = "l",
	[hash("key_m")] = "m",
	[hash("key_n")] = "n",
	[hash("key_o")] = "o",
	[hash("key_p")] = "p",
	[hash("key_q")] = "q",
	[hash("key_r")] = "r",
	[hash("key_s")] = "s",
	[hash("key_t")] = "t",
	[hash("key_u")] = "u",
	[hash("key_v")] = "v",
	[hash("key_w")] = "w",
	[hash("key_x")] = "x",
	[hash("key_y")] = "y",
	[hash("key_z")] = "z",

	[hash("key_lbracket")] = "[",
	[hash("key_rbracket")] = "]",
	[hash("key_backslash")] = "\\",
	[hash("key_caret")] = "^",
	[hash("key_underscore")] = "_",
	[hash("key_grave")] = "`",
	[hash("key_lbrace")] = "{",
	[hash("key_rbrace")] = "}",
	[hash("key_pipe")] = "|",

	[hash("key_esc")] = "esc",

	[hash("key_f1")] = "f1",
	[hash("key_f2")] = "f2",
	[hash("key_f3")] = "f3",
	[hash("key_f4")] = "f4",
	[hash("key_f5")] = "f5",
	[hash("key_f6")] = "f6",
	[hash("key_f7")] = "f7",
	[hash("key_f8")] = "f8",
	[hash("key_f9")] = "f9",
	[hash("key_f10")] = "f10",
	[hash("key_f11")] = "f11",
	[hash("key_f12")] = "f12",

	[hash("key_up")] = "up",
	[hash("key_down")] = "down",
	[hash("key_left")] = "left",
	[hash("key_right")] = "right",

	[hash("key_lshift")] = "lshift",
	[hash("key_rshift")] = "rshift",
	[hash("key_lctrl")] = "lctrl",
	[hash("key_rctrl")] = "rctrl",
	[hash("key_lalt")] = "lalt",
	[hash("key_ralt")] = "ralt",

	[hash("key_tab")] = "tab",
	[hash("key_enter")] = "enter",
	[hash("key_backspace")] = "backspace",
	[hash("key_insert")] = "insert",
	[hash("key_del")] = "delete",
	[hash("key_pageup")] = "pageup",
	[hash("key_pagedown")] = "pagedown",
	[hash("key_home")] = "home",
	[hash("key_end")] = "end",

	[hash("key_numpad_0")] = "num0",
	[hash("key_numpad_1")] = "num1",
	[hash("key_numpad_2")] = "num2",
	[hash("key_numpad_3")] = "num3",
	[hash("key_numpad_4")] = "num4",
	[hash("key_numpad_5")] = "num5",
	[hash("key_numpad_6")] = "num6",
	[hash("key_numpad_7")] = "num7",
	[hash("key_numpad_8")] = "num8",
	[hash("key_numpad_9")] = "num9",
	[hash("key_numpad_divide")] = "num/",
	[hash("key_numpad_multiply")] = "num*",
	[hash("key_numpad_subtract")] = "num-",
	[hash("key_numpad_add")] = "num+",
	[hash("key_numpad_decimal")] = "num.",
	[hash("key_numpad_equal")] = "num=",
	[hash("key_numpad_enter")] = "numenter",
	[hash("key_numpad_numlock")] = "numlock",

	[hash("key_capslock")] = "capslock",
	[hash("key_scrolllock")] = "scrolllock",
	[hash("key_pause")] = "pause",
	[hash("key_lsuper")] = "lsuper",
	[hash("key_rsuper")] = "rsuper",
	[hash("key_menu")] = "menu",
	[hash("key_back")] = "back",

	-- Mouse
	[hash("mouse_wheel_up")] = "wheel_up",
	[hash("mouse_wheel_down")] = "wheel_down",
	[hash("mouse_button_left")] = "mouse_left",
	[hash("mouse_button_middle")] = "mouse_middle",
	[hash("mouse_button_right")] = "mouse_right",
	[hash("mouse_button_1")] = "mouse_1",
	[hash("mouse_button_2")] = "mouse_2",
	[hash("mouse_button_3")] = "mouse_3",
	[hash("mouse_button_4")] = "mouse_4",
	[hash("mouse_button_5")] = "mouse_5",
	[hash("mouse_button_6")] = "mouse_6",
	[hash("mouse_button_7")] = "mouse_7",
	[hash("mouse_button_8")] = "mouse_8",
	[hash("touch")] = "touch",

	-- Gamepad
	[hash("gamepad_lstick_left")] = "gp_lstick_left",
	[hash("gamepad_lstick_right")] = "gp_lstick_right",
	[hash("gamepad_lstick_down")] = "gp_lstick_down",
	[hash("gamepad_lstick_up")] = "gp_lstick_up",
	[hash("gamepad_lstick_click")] = "gp_lstick_click",
	[hash("gamepad_ltrigger")] = "gp_ltrigger",
	[hash("gamepad_lshoulder")] = "gp_lshoulder",
	[hash("gamepad_lpad_left")] = "gp_lpad_left",
	[hash("gamepad_lpad_right")] = "gp_lpad_right",
	[hash("gamepad_lpad_down")] = "gp_lpad_down",
	[hash("gamepad_lpad_up")] = "gp_lpad_up",

	[hash("gamepad_rstick_left")] = "gp_rstick_left",
	[hash("gamepad_rstick_right")] = "gp_rstick_right",
	[hash("gamepad_rstick_down")] = "gp_rstick_down",
	[hash("gamepad_rstick_up")] = "gp_rstick_up",
	[hash("gamepad_rstick_click")] = "gp_rstick_click",
	[hash("gamepad_rtrigger")] = "gp_rtrigger",
	[hash("gamepad_rshoulder")] = "gp_rshoulder",
	[hash("gamepad_rpad_left")] = "gp_rpad_left",
	[hash("gamepad_rpad_right")] = "gp_rpad_right",
	[hash("gamepad_rpad_down")] = "gp_rpad_down",
	[hash("gamepad_rpad_up")] = "gp_rpad_up",

	[hash("gamepad_start")] = "gp_start",
	[hash("gamepad_back")] = "gp_back",
	[hash("gamepad_guide")] = "gp_guide",
	[hash("gamepad_connected")] = "gp_connected",
	[hash("gamepad_disconnected")] = "gp_disconnected",
}


local function label_from_action_name(action_name)
	if not action_name then
		return "?"
	end
	local label = action_id_to_label[hash(action_name)]
	if label then
		return string.upper(label)
	end
	label = action_name
	label = label:gsub("^key_", "")
	label = label:gsub("^mouse_button_", "mouse_")
	label = label:gsub("^gamepad_", "gp_")
	return string.upper(label)
end

-- write correct keys into text nodes 
local function update_key_labels_from_state()
	gui.set_text(gui.get_node("left_key"), label_from_action_name(save.get_action_name("key_left")))
	gui.set_text(gui.get_node("right_key"), label_from_action_name(save.get_action_name("key_right")))
	gui.set_text(gui.get_node("pause_key"), label_from_action_name(save.get_action_name("key_pause")))
end


local function action_name_from_hash(action_id)
	return tostring(action_id):match("%[(.-)%]")
end

-- changes colour of active node of key to remap
local function set_active_mapping_frame(active_frame)
	local frames = {
		frame_left,
		frame_right,
		frame_pause,
	}
	for _, node in ipairs(frames) do
		gui.set_color(node, node == active_frame and G.UI_pink or G.UI_orange)
	end
end


local function enter_remapped_key(self, mapping, action_id, action)
	-- don't allow keys already set to be used twice
	if action_id == states.key_left or action_id == states.key_right or action_id == states.key_pause then 
		print("not assigning anything")
		return
	end
	-- exclude a bunch of mouse acitons for keyboard-oriented games, change/delete as needed
	if action_id == hash("touch") 
	or action_id == hash("mouse_button_left")
	or action_id == hash("mouse_button_1")
	or action_id == hash("mouse_button_4")
	then 
		return 
	end
	local key_label
	if action_id == hash("type") then
		print("key pressed", action_id)
		if string.len(action.text) == 1 then
			key_label = action.text
			if key_label == " " then key_label = "space" end
		else return
		end
	else
		key_label = action_id_to_label[action_id]
	end
	gui.set_text(mapping.node, string.upper(key_label)) -- display text in uppercase, change as needed
	local action_name
	if action_id == hash("type") then
		action_name = "key_" .. key_label
	else
		action_name = action_name_from_hash(action_id)
	end
	if not action_name then
		print("COULD NOT SAVE BINDING:", action_id)
		return
	end
	save.set_binding(mapping.name, action_name)
	self.active_mapping = nil
	-- let buttons return to default colour
	set_active_mapping_frame(nil)
end


local function click_is_on_mapping_button(action, left, right, pause)
	return gui.pick_node(left, action.x, action.y)
	or gui.pick_node(right, action.x, action.y)
	or gui.pick_node(pause, action.x, action.y)
end


function on_input(self, action_id, action)
	-- all remappable buttons
	local left = gui.get_node("left_key")
	local right = gui.get_node("right_key")
	local pause = gui.get_node("pause_key")

	if action_id == hash("touch") and action.released then
		--reset colour of remappable buttons' fields when clicking outside of them
		if self.active_mapping and not click_is_on_mapping_button(action, left, right, pause) then
			self.active_mapping = nil
			set_active_mapping_frame(nil)
			return true
		end
		if gui.pick_node(left, action.x, action.y) then
			self.active_mapping = { node = left, name = "key_left" }
			set_active_mapping_frame(frame_left)
		elseif gui.pick_node(right, action.x, action.y) then
			self.active_mapping = { node = right, name = "key_right" }
			set_active_mapping_frame(frame_right)
		elseif gui.pick_node(pause, action.x, action.y) then
			self.active_mapping = { node = pause, name = "key_pause" }
			set_active_mapping_frame(frame_pause)
		end
	end	
	if self.active_mapping and (action_id == hash("type") or action.released) then
		enter_remapped_key(self, self.active_mapping, action_id, action)
	end
	U.button_hover_effects(self, action_id, action)
end


-- put in GUI script's init()
self.active_mapping = nil
update_key_labels_from_state()


return M