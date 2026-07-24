--[[
	COSMIC HUB — Settings Module
	Flag persistence and config management.
]]
return function(Hub)
	local Settings = {}
	local Env = Hub.Environment
	local HttpService = Env.Services.HttpService

	local SETTINGS_FILE = "CosmicHub_Settings.json"
	local currentSettings = {}

	--// Default settings
	local defaults = {
		AutoFarm = false,
		AutoFarm_Method = "Level",
		AutoFarm_Range = 50,
		Teleport_Mode = "Instant",
		ESP_Enabled = false,
		ESP_Players = false,
		AutoStats = false,
		AutoStats_Type = "Melee",
		AutoHaki = false,
		AutoBusoHaki = false,
		AutoKenHaki = false,
		AutoCollectFruits = false,
		AutoStoreFruits = false,
		FruitNotifier_Enabled = false,
		FruitNotifier_Fruits = {},
		WalkSpeed = 16,
		JumpPower = 50,
		FlySpeed = 50,
		NoClip = false,
		InfinityJump = false,
		AutoBuyBuso = false,
		AutoBuyKen = false,
		AutoBuyGeppo = false,
		AutoBuySoru = false,
	}

	function Settings:Load()
		if writefile and readfile then
			local success, data = pcall(function()
				return readfile(SETTINGS_FILE)
			end)
			if success and data then
				local decoded = HttpService:JSONDecode(data)
				for k, v in pairs(decoded) do
					defaults[k] = v
				end
			end
		end
		return defaults
	end

	function Settings:Save(flags)
		if writefile then
			local data = HttpService:JSONEncode(flags)
			pcall(function()
				writefile(SETTINGS_FILE, data)
			end)
		end
	end

	function Settings:RestoreFlags(Hub)
		local saved = self:Load()

		-- Apply saved flags to UI toggles if UI is loaded
		if Hub.UI then
			local windowFlags = Hub.UI:GetFlags()
			for flag, value in pairs(saved) do
				if windowFlags[flag] ~= nil then
					-- We don't have SetValue on all elements stored centrally,
					-- but windowFlags holds current state
					windowFlags[flag] = value
				end
			end
		end

		Hub.Flags = saved
	end

	function Settings:SaveFlags(Hub)
		if Hub.UI then
			local flags = Hub.UI:GetFlags()
			self:Save(flags)
		end
	end

	-- Auto-save on game close
	if game then
		game:BindToClose(function()
			if Hub.UI then
				Settings:Save(Hub.UI:GetFlags())
			end
		end)
	end

	Hub.Modules["Settings"] = Settings

	return Settings
end
