local states = require "main.states"

local M = {}

local FILE_NAME = "highscores"
local MAX_ENTRIES = 10

-- Load or create an empty table
function M.load()
	M.scores = sys.load(FILE_NAME) or {}
	M.scores.entries = M.scores.entries or { { name = "Noppi", score = 90 }, { name = "Make it a Triple", score = 100 } }
end

-- Save the current scores
function M.save()
	sys.save(FILE_NAME, M.scores)
end


function M.is_valid_highscore()
	local score = states.total_score
	local entries = M.scores.entries

	-- Sort descending
	table.sort(entries, function(a, b) return a.score > b.score end)

	local last_entry = entries[#entries]
	return score > last_entry["score"]
end


-- Add a new score if it's good enough
function M.try_add_score(name, score)
	
	local entries = M.scores.entries
	table.insert(entries, { name = name, score = score })

	-- Sort descending
	table.sort(entries, function(a, b) return a.score > b.score end)

	-- Trim
	while #entries > MAX_ENTRIES do
		table.remove(entries)
	end

	M.save()
end


-- Get the current score table
function M.get_scores()
	return M.scores.entries
end

return M