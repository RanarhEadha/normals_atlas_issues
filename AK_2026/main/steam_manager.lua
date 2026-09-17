-- local steam = require "steam"
-- add to a script that runs from startup: 
-- local steam_manager = require "main.steam_manager"
-- steam_manager.init() 

local M = {}
M.initialized = false
M.achievements_handled = {}

function M.update()
	if M.initialized then
		steam.update()
	end
end


function M.final()
	if M.initialized then
		steam.final()
		M.initialized = false
	end
end


function M.unlock_achievement(api_name)
	if M.achievements_handled[api_name] then
		return true
	end

	M.achievements_handled[api_name] = true

	if not M.initialized then
		print("STEAM ACHIEVEMENT SKIPPED, NOT INITIALIZED:", api_name)
		return false
	end

	local ok = steam.user_stats_set_achievement(api_name)
	if not ok then
		print("STEAM ACHIEVEMENT FAILED:", api_name)
		return false
	end

	steam.user_stats_store_stats()
	print("STEAM ACHIEVEMENT UNLOCKED:", api_name)
	return true
end


function M.set_stat_int(api_name, value)
	if not M.initialized then
		print("STEAM STAT SKIPPED, NOT INITIALIZED:", api_name, value)
		return false
	end

	local got_current, current_value = steam.user_stats_get_stat_int(api_name)
	print("STEAM STAT CURRENT:", api_name, got_current, current_value)

	if got_current and current_value ~= nil and value < current_value then
		print("STEAM STAT SKIPPED, WOULD DECREASE:", api_name, current_value, "->", value)
		return false
	end

	local ok = steam.user_stats_set_stat_int(api_name, value)
	if not ok then
		print("STEAM STAT FAILED:", api_name, value)
		return false
	end

	steam.user_stats_store_stats()
	print("STEAM STAT SET:", api_name, value)
	return true
end


function M.init()
	local ok, err = steam.init()
	if not ok then
		print("STEAM INIT FAILED:", err)
		return false
	end

	M.initialized = true
	M.stats_ready = false

	steam.set_listener(function(self, event, data)
		print("STEAM EVENT:", event)

		if event == "UserStatsReceived_t" then
			M.stats_ready = true
			print("STEAM STATS READY")
		end
	end)

	local requested = steam.user_stats_request_current_stats()
	print("STEAM REQUEST CURRENT STATS:", requested)
	print("STEAM INIT OK")

	return true
end

return M