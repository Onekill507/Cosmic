--[[
	COSMIC HUB — Game Initializer
	Detects game and loads appropriate module set.
]]
return function(Hub)
	local GameInit = {}
	local Env = Hub.Environment

	local BLOCK_FRUITS_ID = 2753915549 -- Blox Fruits Place ID
	local BLOCK_FRUITS_ID_2 = 4442272183 -- Blox Fruits (Alt)

	local currentPlaceId = game.PlaceId

	-- Verify game
	if currentPlaceId == BLOCK_FRUITS_ID or currentPlaceId == BLOCK_FRUITS_ID_2 then
		print("[COSMIC] Blox Fruits detected! Loading Sea 1 modules...")

		-- Load Blox Fruits specific modules
		Hub:LoadModule("Game/BloxFruits/Quests")
		Hub:LoadModule("Game/BloxFruits/Bosses")
		Hub:LoadModule("Game/BloxFruits/SeaEvents")

		-- Initialize game-specific features
		local Quests = Hub.Modules["Quests"]
		local Bosses = Hub.Modules["Bosses"]
		local SeaEvents = Hub.Modules["SeaEvents"]

		if Quests then
			Quests:Init(Hub)
			print("[COSMIC] Quest module initialized")
		end
		if Bosses then
			Bosses:Init(Hub)
			print("[COSMIC] Boss module initialized")
		end
		if SeaEvents then
			SeaEvents:Init(Hub)
			print("[COSMIC] Sea Events module initialized")
		end

	else
		print("[COSMIC] Unknown game detected (PlaceId: " .. currentPlaceId .. "). Loading universal modules only.")
		Hub:LoadModule("Game/Universal")
		if Hub.Modules["Universal"] then
			Hub.Modules["Universal"]:Init(Hub)
		end
	end

	Hub.Modules["GameInit"] = GameInit

	return GameInit
end
