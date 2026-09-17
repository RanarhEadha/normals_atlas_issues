-- handles vertical scrollbars. This case uses data given from level_overview proxy

local G = {}

local drag = { active = false, target = nil }
local STEP = 0.05
local bars = { }
local scroll_value = 0


local function apply_scroll(node, overview_height, viewport_height, viewport_pos)
	local in_view = overview_height - viewport_height
	if in_view <= 0 then return end

	local scroll_offset = scroll_value * in_view
	gui.set_position(node, vmath.vector3(
	viewport_pos.x,
	viewport_pos.y + scroll_offset,
	viewport_pos.z
))
end


local function update_knob_from_scroll(bar)
	local bar_top = gui.get_position(bar.parent).y
	local bar_bottom = bar_top - bar.fullsize.y

	local clamped_y = bar_bottom - scroll_value * bar.fullsize.y

	local knob_pos = gui.get_position(bar.knob)
	knob_pos.y = -scroll_value * bar.fullsize.y	
	gui.set_position(bar.knob, knob_pos)
end


function G.slider_move(action_id, action)
	if action_id == hash("touch") and action.pressed then
		for key, bar in pairs(bars) do
			if gui.pick_node(bar.knob, action.x, action.y) then
				drag.active = true
				drag.target = key

				local bar_top = gui.get_position(bar.parent).y
				local bar_bottom = bar_top - bar.fullsize.y
				local clamped_y = math.max(bar_bottom, math.min(action.y, bar_top))

				scroll_value = (bar_top - clamped_y) / bar.fullsize.y
				update_knob_from_scroll(bar)
				break
			end
		end
	end
end


function G.on_drag(action)
	if drag.active and action.y then
		local bar = bars[drag.target]
		if not bar then return end

		local bar_top = gui.get_position(bar.parent).y
		local bar_bottom = bar_top - bar.fullsize.y
		local clamped_y = math.max(bar_bottom, math.min(action.y, bar_top))

		scroll_value = (bar_top - clamped_y) / bar.fullsize.y		
		update_knob_from_scroll(bar)
		apply_scroll(
		G.node,
		G.overview_height,
		G.viewport_height,
		G.viewport_pos
	)
	

		if action.released then
			drag.active = false
			drag.target = nil
		end
	end
end


function G.scrolling(node, overview_height, viewport_height, viewport_pos, action_id)
	G.node = node
	G.overview_height = overview_height
	G.viewport_height = viewport_height
	G.viewport_pos = viewport_pos
	
	local in_view = overview_height - viewport_height
	if in_view <= 0 then return end

	if action_id == hash("mouse_wheel_up") then
		scroll_value = math.max(0, scroll_value - STEP)
	elseif action_id == hash("mouse_wheel_down") then
		scroll_value = math.min(1, scroll_value + STEP)
	else
		return
	end

	-- move content
	apply_scroll(node, overview_height, viewport_height, viewport_pos)
	update_knob_from_scroll(bars.vertical)	
end


function G.init()
	bars.vertical = {
		bar = gui.get_node("bar"),
		knob = gui.get_node("knob"),
		parent = gui.get_node("scrollbar_container"),
	}
	bars.vertical.fullsize = gui.get_size(bars.vertical.bar)

	scroll_value = 0
	update_knob_from_scroll(bars.vertical)
end

return G