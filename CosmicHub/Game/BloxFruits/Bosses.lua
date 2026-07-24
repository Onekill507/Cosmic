--[[
	COSMIC HUB — Blox Fruits Boss Module
	Auto boss farming for Sea 1.
]]
return function(Hub)
	local Bosses = {}
	local Functions = Hub.Modules["Functions"]
	local Connections = Hub.Modules["Connections"]
	local RunService = Hub.Environment.Services.RunService

	-- Sea 1 Boss Database
	local bossData = {
		-- First Sea Bosses
		{name = "Gorilla King", level = 25, location = CFrame.new(-1424, 13, -943), respawn = 180, drops = {"Gorilla Crown"}},
		{name = "Bobby", level = 55, location = CFrame.new(-1424, 13, -943), respawn = 180, drops = {"Bobby's Helmet"}},
		{name = "Yeti", level = 105, location = CFrame.new(1163, 15, -6951), respawn = 180, drops = {"Yeti Fur"}},
		{name = "Mob Leader", level = 120, location = CFrame.new(-1424, 13, -943), respawn = 180, drops = {"Boss Drop"}},
		{name = "Vice Admiral", level = 130, location = CFrame.new(-4977, 30, 1150), respawn = 300, drops = {"Bisento"}},
		{name = "Warden", level = 220, location = CFrame.new(5609, 50, 760), respawn = 240, drops = {"Warden's Sword"}},
		{name = "Chief Warden", level = 230, location = CFrame.new(5609, 50, 760), respawn = 240, drops = {"Warden's Helmet"}},
		{name = "Swan", level = 240, location = CFrame.new(5807, 50, 1289), respawn = 180, drops = {"Swan Glasses"}},
		{name = "Magma Admiral", level = 350, location = CFrame.new(-5213, 30, 8759), respawn = 300, drops = {"Magma Ore"}},
		{name = "Fishman Lord", level = 425, location = CFrame.new(3855, -45, -1938), respawn = 240, drops = {"Trident"}},
		{name = "Wysper", level = 500, location = CFrame.new(-4977, 810, -590), respawn = 360, drops = {"Wysper's Coat"}},
		{name = "Thunder God", level = 575, location = CFrame.new(-4977, 810, -590), respawn = 600, drops = {"Pole (1st Form)", "Rumble Fruit"}},
		{name = "Cyborg", level = 675, location = CFrame.new(6200, 30, 1572), respawn = 360, drops = {"Cyborg's Helmet"}},
		{name = "Greybeard", level = 750, location = CFrame.new(-4977, 30, -2844), respawn = 900, drops = {"Bisento v2", "Gravity Fruit"}},
	}

	local currentBossTarget = nil
	local bossLoopActive = false

	function Bosses:FindBoss(bossName)
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and v.Name:lower():find(bossName:lower()) then
				local humanoid = v:FindFirstChild("Humanoid")
				local hrp = v:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and hrp then
					return {Model = v, Humanoid = humanoid, RootPart = hrp, Name = v.Name}
				end
			end
		end
		return nil
	end

	function Bosses:FarmBoss(bossInfo)
		if not Functions:IsAlive() then return end

		local boss = Bosses:FindBoss(bossInfo.name)
		if not boss then
			-- Boss not spawned, wait at location
			Functions:TeleportTo(bossInfo.location)
			return false
		end

		-- Found boss, attack it
		local dist = Functions:GetMagnitude(boss.RootPart)
		if dist < 200 then
			Functions:TeleportTo(boss.RootPart.CFrame * CFrame.new(0, 0, 5))
			task.wait(0.1)
			Functions:Click()
			return true
		else
			Functions:TeleportTo(bossInfo.location)
			return false
		end
	end

	function Bosses:GetBossByLevel(level)
		local best = nil
		for _, boss in ipairs(bossData) do
			if level >= boss.level then
				if not best or boss.level > best.level then
					best = boss
				end
			end
		end

		-- If no available boss, return highest
		if not best then
			return bossData[#bossData]
		end

		return best
	end

	function Bosses:IsBossAlive(bossName)
		local boss = Bosses:FindBoss(bossName)
		return boss ~= nil
	end

	function Bosses:Init(Hub)
		Bosses.Hub = Hub

		-- Hook boss farming into auto farm
		Connections:StartLoop("BossFarm", 0.5, function()
			if not Hub.Flags.AutoFarm or Hub.Flags.AutoFarm_Method ~= "Boss" then
				if bossLoopActive then
					bossLoopActive = false
					Functions:Notify("Boss", "Boss farming paused")
				end
				return
			end

			if not Functions:IsAlive() then return end

			bossLoopActive = true

			-- Get player level to determine which boss
			local ls = Hub.Environment.LocalPlayer:FindFirstChild("leaderstats")
			local playerLevel = 0
			if ls then
				local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("level")
				if lv and lv:IsA("IntValue") then
					playerLevel = lv.Value
				end
			end

			-- If current boss is alive, keep farming
			if currentBossTarget and Bosses:IsBossAlive(currentBossTarget.name) then
				Bosses:FarmBoss(currentBossTarget)
			else
				-- Get next boss to farm
				currentBossTarget = Bosses:GetBossByLevel(playerLevel)
				if currentBossTarget then
					Functions:Notify("Boss", "Farming: " .. currentBossTarget.name)
					-- Wait at boss spawn location
					Functions:TeleportTo(currentBossTarget.location)
				end
			end
		end)
	end

	Bosses.GetBossData = function()
		return bossData
	end

	Hub.Modules["Bosses"] = Bosses

	return Bosses
end
