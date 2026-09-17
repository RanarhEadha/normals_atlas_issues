-- local U = require "main.utilities"


local U = {}

function b2i(value)--returns 1 or 0 from true or false
	if value then
		return 1
	end
	return 0
end


-- Norman's sort-and-roll function
local function roll_table(chance_table)
	local thresholds = {}
	for threshold in pairs(chance_table) do
		table.insert(thresholds, threshold)
	end
	table.sort(thresholds)  -- Sort the keys in ascending order

	-- Generate a random number between 0 and 1
	local random_value = math.random()

	-- Iterate through the sorted thresholds
	for _, threshold in ipairs(thresholds) do
		if random_value <= threshold then
			return chance_table[threshold]
		end
	end
	return nil
end

-- scale buttons slightly bigger on mouseover and down again after
-- "buttons" is the table of nodes or whatever
function U.button_hover_effects(self, action, buttons)
	local default_scale = vmath.vector3(1, 1, 1)
	local hover_scale = vmath.vector3(1.2, 1.2, 1)
	local hovered_button = nil
	if action.x == nil or action.y == nil then return end
	for _, button_id in ipairs(buttons) do
		local button_node = gui.get_node(button_id)
		if gui.pick_node(button_node, action.x, action.y) then
			hovered_button = button_id
			gui.set_scale(button_node, hover_scale)
		else
			gui.set_scale(button_node, default_scale)
		end
	end
	if hovered_button and hovered_button ~= self.hovered_button then
		msg.post("manager:/controller_audio#audio", "play_sfx")
	end
	self.hovered_button = hovered_button
end



function U.move_caret()
	local node = gui.get_node("enter_name") -- node / editable field to move caret in
	local cursor = gui.get_node("cursor") -- node of the caret itself
	local font = gui.get_font_resource(gui.get_font(node))
	local player_name = gui.get_text(node)
	local metrics = resource.get_text_metrics(font, player_name)

	local base_pos = gui.get_position(node)
	local cursor_pos = vmath.vector3(base_pos.x + metrics.width + 5, base_pos.y, base_pos.z)
	gui.set_position(cursor, cursor_pos)
end


-- functionality to enter player names that will be given with scores into a highscore board
-- requires variable "score" to be defined
local leaderboard = require "main.highscore"
function U.enter_player_highscore(self, action_id, action)
	local name = gui.get_node("enter_name")

	if action_id == hash("key_enter") and action.pressed then
		if self.player_name ~= "" then
			leaderboard.try_add_score(self.player_name, score)
			score = 0
			gui.set_enabled(gui.get_node("player_data"), false) -- disabled noce for entering player name
			self.player_name = ""
			U.build_highscore_table(self)
		end

		-- allows player names up to twenty characters length
	elseif action_id == hash("text") then
		local next_name = self.player_name .. action.text
		if string.len(next_name) <= 20 then
			self.player_name = next_name
			gui.set_text(name, self.player_name)
			U.move_caret()
		end
-- functionality for using backspace to correct typed input
	elseif action_id == hash("key_backspace") and (action.pressed or action.repeated) then
		local len = math.min(20, string.len(self.player_name))
		self.player_name = string.sub(self.player_name, 1, len - 1)
		gui.set_text(name, self.player_name)
		U.move_caret()
	end
end



-- creates a highscore board by cloning nodes of names and scores
-- requires variable "score" to be defined
local leaderboard = require "main.highscore"
function U.build_highscore_table(self)
	gui.set_text(gui.get_node("new_highscore"), score) -- node to enter player name in and score var

	if self.rows then
		for i = #self.rows, 1, -1 do
			local row = self.rows[i]
			for _, node in pairs(row.nodes) do
				gui.delete_node(node)
			end
			self.rows[i] = nil
		end
	end
	self.rows = {  }

	local scores = leaderboard.get_scores()
	-- overwrite placeholders at default 1st place
	if #scores >= 1 then
		gui.set_text(gui.get_node("name"), scores[1].name or "...")
		gui.set_text(gui.get_node("score"), tostring(scores[1].score or ""))
	else 
		gui.set_text(gui.get_node("name"), "...")
		gui.set_text(gui.get_node("score"), "")
	end

	for i = 2, #scores do
		local nodes = gui.clone_tree(self.template_node)
		local row_root = nodes[self.id_template_row]
		local name_node = nodes[self.id_name]
		local score_node= nodes[self.id_score]
		gui.set_text(name_node, scores[i].name)
		gui.set_text(score_node, tostring(scores[i].score))	
		local offset = vmath.vector3(0, -60 * (i - 1), 0)
		gui.set_position(row_root, self.base_pos + offset)
		table.insert(self.rows, { nodes = nodes, root = row_root, name = name_node, score = score_node })
	end
end


return U