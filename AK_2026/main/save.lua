local M = {}

local FILE = "savefile"

function M.load()
	local data = sys.load(FILE)
	if next(data) == nil then
		return nil
	end
	return data
end

function M.save(state)
	sys.save(FILE, state)
end

function M.reset(default_state)
	sys.save(FILE, default_state)
end

return M