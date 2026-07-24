--[[
	COSMIC HUB — Blox Fruits Quest Module
	Handles auto-questing for Sea 1 leveling.
]]
return function(Hub)
	local Quests = {}
	local Functions = Hub.Modules["Functions"]
	local Connections = Hub.Modules["Connections"]
	local LocalPlayer = Hub.Environment.LocalPlayer

	-- Quest NPC database (Sea 1)
	local questData = {
		-- Starter Island / Pirate Village
		{level = 0, npc = "Bandit", questNpc = "Bandit Quest Giver", location = CFrame.new(-484, 16, -1070)},
		{level = 30, npc = "Monkey", questNpc = "Monkey Quest Giver", location = CFrame.new(-838, 30, 3926)},
		{level = 60, npc = "Pirate", questNpc = "Pirate Quest Giver", location = CFrame.new(-968, 30, 1150)},
		{level = 90, npc = "Brute", questNpc = "Brute Quest Giver", location = CFrame.new(-968, 30, 1150)},
		{level = 120, npc = "Desert Bandit", questNpc = "Desert Quest Giver", location = CFrame.new(902, 30, 3392)},
		{level = 150, npc = "Desert Officer", questNpc = "Desert Quest Giver 2", location = CFrame.new(902, 30, 3392)},
		{level = 190, npc = "Soldier", questNpc = "Soldier Quest Giver", location = CFrame.new(-5653, 30, 1811)},
		{level = 220, npc = "Marine Lieutenant", questNpc = "Marine Quest Giver 2", location = CFrame.new(-5653, 30, 1811)},
		{level = 250, npc = "Snow Bandit", questNpc = "Snow Quest Giver", location = CFrame.new(1347, 30, -6185)},
		{level = 275, npc = "Snowman", questNpc = "Snow Quest Giver 2", location = CFrame.new(1347, 30, -6185)},
		{level = 300, npc = "Chief Petty Officer", questNpc = "Marine Quest Giver 3", location = CFrame.new(-5653, 30, 1811)},
		{level = 330, npc = "Sky Bandit", questNpc = "Sky Quest Giver", location = CFrame.new(-4977, 800, -590)},
		{level = 375, npc = "Dark Master", questNpc = "Sky Quest Giver 2", location = CFrame.new(-4977, 800, -590)},
		{level = 425, npc = "Prisoner", questNpc = "Prison Quest Giver", location = CFrame.new(5591, 30, 763)},
		{level = 475, npc = "Dangerous Prisoner", questNpc = "Prison Quest Giver 2", location = CFrame.new(5591, 30, 763)},
		{level = 525, npc = "Gladiator", questNpc = "Colosseum Quest Giver", location = CFrame.new(-1573, 30, 2944)},
		{level = 575, npc = "Magma Admiral", questNpc = "Magma Quest Giver", location = CFrame.new(-5222, 30, 8746)},
		{level = 625, npc = "Fishman Warrior", questNpc = "Fishman Quest Giver", location = CFrame.new(3879, -50, -1937)},
		{level = 675, npc = "Fishman Commando", questNpc = "Fishman Quest Giver 2", location = CFrame.new(3879, -50, -1937)},
		{level = 725, npc = "God's Guard", questNpc = "Sky Quest Giver 3", location = CFrame.new(-4977, 800, -590)},
		{level = 775, npc = "Shanda", questNpc = "Jungle Quest Giver", location = CFrame.new(-1250, 30, -1750)},
	}

	local currentQuestNPC = nil
	local currentKillNPC = nil
	local questActive = false

	function Quests:GetCurrentLevel()
		local humanoid = Functions:GetHumanoid()
		if not humanoid then return 0 end
		-- Get level from leaderstats
		local ls = LocalPlayer:FindFirstChild("leaderstats")
		if ls then
			local level = ls:FindFirstChild("Level") or ls:FindFirstChild("level")
			if level and level:IsA("IntValue") then
				return level.Value
			end
		end
		return 0
	end

	function Quests:GetBestQuest()
		local level = self:GetCurrentLevel()
		local best = questData[1]

		for _, quest in ipairs(questData) do
			if level >= quest.level then
				best = quest
			end
		end

		return best
	end

	function Quests:StartQuest(questNpc)
		local npc = Functions:GetQuestNPC(questNpc)
		if npc then
			Functions:TeleportTo(npc.CFrame * CFrame.new(0, 0, 3))
			task.wait(0.3)
			-- Click to interact
			Functions:Click()
			task.wait(0.5)
			-- Look for quest dialog accept button
			local gui = LocalPlayer.PlayerGui
			if gui then
				for _, btn in ipairs(gui:GetDescendants()) do
					if btn:IsA("TextButton") and (btn.Text:lower():find("accept") or btn.Text:lower():find("yes")) then
						pcall(function() btn:Invoke() end)
						return true
					end
				end
			end
		end
		return false
	end

	function Quests:Init(Hub)
		Quests.Hub = Hub

		-- Hook into the auto farm loop
		Connections:StartLoop("QuestLogic", 0.5, function()
			if not Hub.Flags.AutoFarm or Hub.Flags.AutoFarm_Method ~= "Quest" then
				return
			end

			if not Functions:IsAlive() then return end

			local quest = Quests:GetBestQuest()
			if not quest then return end

			local level = Quests:GetCurrentLevel()

			-- Check if we need a new quest
			local shouldReQuest = not questActive
				or (currentQuestNPC and currentQuestNPC ~= quest.questNpc)

			if shouldReQuest then
				Quests:StartQuest(quest.questNpc)
				currentQuestNPC = quest.questNpc
				currentKillNPC = quest.npc
				questActive = true
			end

			-- Go farm the npc
			if questActive and currentKillNPC then
				local nearest = nil
				local nearestDist = 100

				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("Model") and v.Name:lower():find(currentKillNPC:lower()) then
						local humanoid = v:FindFirstChild("Humanoid")
						local hrp = v:FindFirstChild("HumanoidRootPart")
						if humanoid and humanoid.Health > 0 and hrp then
							local dist = Functions:GetMagnitude(hrp)
							if dist < nearestDist then
								nearestDist = dist
								nearest = {RootPart = hrp, Humanoid = humanoid}
							end
						end
					end
				end

				if nearest then
					Functions:TeleportTo(nearest.RootPart.CFrame * CFrame.new(0, 0, 3))
					task.wait(0.1)
					Functions:Click()
				end
			end
		end)
	end

	Quests.GetQuestData = function()
		return questData
	end

	Hub.Modules["Quests"] = Quests

	return Quests
end
