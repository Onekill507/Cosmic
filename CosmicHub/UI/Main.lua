--[[
	COSMIC HUB — UI Builder
	Constructs all tabs, sections, and element callbacks.
]]
return function(Hub, Fluent)
	local UI = {}
	local Functions = Hub.Modules["Functions"]
	local Connections = Hub.Modules["Connections"]
	local Settings = Hub.Modules["Settings"]

	-- Create Window
	local Window = Fluent.CreateWindow({
		Title = "Cosmic Hub",
		SubTitle = "Blox Fruits | Sea 1 | Kaitun",
		TabWidth = 160,
		Size = UDim2.fromOffset(620, 440),
		Theme = "Cosmic",
		MinimizeKey = Enum.KeyCode.RightControl
	})

	-- ========================
	-- TAB 1: Farming
	-- ========================
	local FarmTab = Window:CreateTab({
		Name = "Farming",
		Icon = "⚔️"
	})

	local AutoFarmSection = FarmTab:CreateSection("Auto Farm")
	AutoFarmSection:AddToggle({
		Name = "Auto Farm",
		Default = false,
		Flag = "AutoFarm",
		Callback = function(state)
			if state then
				Connections:StartLoop("AutoFarm", 0.2, function()
					if not Hub.Flags.AutoFarm then
						Connections:StopLoop("AutoFarm")
						return
					end
					local method = Hub.Flags.AutoFarm_Method or "Level"
					local range = Hub.Flags.AutoFarm_Range or 50

					if method == "Level" then
						local nearest = Functions:GetNearestNPC(range)
						if nearest then
							Functions:TeleportTo(nearest.RootPart.CFrame * CFrame.new(0, 0, 3))
							task.wait(0.05)
							Functions:Click()
						end
					elseif method == "Boss" then
						local nearest = Functions:GetNearestEnemy(range, false)
						if nearest then
							Functions:TeleportTo(nearest.RootPart.CFrame * CFrame.new(0, 0, 3))
							task.wait(0.05)
							Functions:Click()
						end
					end
				end)
				Functions:Notify("Farm", "Auto Farm started!")
			else
				Connections:StopLoop("AutoFarm")
				Functions:Notify("Farm", "Auto Farm stopped!")
			end
		end
	})

	AutoFarmSection:AddDropdown({
		Name = "Farm Method",
		Options = {"Level", "Boss", "Quest", "Chest"},
		Default = "Level",
		Flag = "AutoFarm_Method",
		Callback = function(val) end
	})

	AutoFarmSection:AddSlider({
		Name = "Farm Range",
		Min = 10,
		Max = 500,
		Default = 50,
		Suffix = " studs",
		Flag = "AutoFarm_Range",
		Callback = function(val) end
	})

	local MiscFarmSection = FarmTab:CreateSection("Misc Farm")
	MiscFarmSection:AddToggle({
		Name = "Auto Equip Best Weapon",
		Default = false,
		Flag = "AutoEquipWeapon",
		Callback = function(state) end
	})

	MiscFarmSection:AddToggle({
		Name = "Auto Collect Drops",
		Default = false,
		Flag = "AutoCollectDrops",
		Callback = function(state) end
	})

	MiscFarmSection:AddToggle({
		Name = "Bring Mob",
		Default = false,
		Flag = "BringMob",
		Callback = function(state)
			if state then
				Connections:StartLoop("BringMob", 0.1, function()
					if not Hub.Flags.BringMob then
						Connections:StopLoop("BringMob")
						return
					end
					local nearest = Functions:GetNearestNPC(100)
					if nearest then
						Functions:BringEntity(nearest.RootPart)
					end
				end)
			else
				Connections:StopLoop("BringMob")
			end
		end
	})

	-- ========================
	-- TAB 2: Player
	-- ========================
	local PlayerTab = Window:CreateTab({
		Name = "Player",
		Icon = "🧑"
	})

	local MovementSection = PlayerTab:CreateSection("Movement")
	MovementSection:AddSlider({
		Name = "Walk Speed",
		Min = 16,
		Max = 400,
		Default = 16,
		Suffix = "",
		Flag = "WalkSpeed",
		Callback = function(val)
			Functions:SetWalkSpeed(val)
		end
	})

	MovementSection:AddSlider({
		Name = "Jump Power",
		Min = 50,
		Max = 500,
		Default = 50,
		Suffix = "",
		Flag = "JumpPower",
		Callback = function(val)
			Functions:SetJumpPower(val)
		end
	})

	MovementSection:AddToggle({
		Name = "Infinity Jump",
		Default = false,
		Flag = "InfinityJump",
		Callback = function(state)
			if state then
				Connections:StartLoop("InfinityJump", 0.05, function()
					if not Hub.Flags.InfinityJump then
						Connections:StopLoop("InfinityJump")
						return
					end
					local humanoid = Functions:GetHumanoid()
					if humanoid and humanoid.FloorMaterial == Enum.Material.Air then
						humanoid.Jump = true
					end
				end)
			else
				Connections:StopLoop("InfinityJump")
			end
		end
	})

	MovementSection:AddToggle({
		Name = "No Clip",
		Default = false,
		Flag = "NoClip",
		Callback = function(state)
			if state then
				Connections:StartLoop("NoClip", 0.01, function()
					if not Hub.Flags.NoClip then
						Connections:StopLoop("NoClip")
						return
					end
					local char = Functions:GetCharacter()
					if char then
						for _, part in ipairs(char:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
							end
						end
					end
				end)
			else
				Connections:StopLoop("NoClip")
				local char = Functions:GetCharacter()
				if char then
					for _, part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = true
						end
					end
				end
			end
		end
	})

	local CombatSection = PlayerTab:CreateSection("Combat")
	CombatSection:AddToggle({
		Name = "Auto Stats",
		Default = false,
		Flag = "AutoStats",
		Callback = function(state) end
	})

	CombatSection:AddDropdown({
		Name = "Stats Type",
		Options = {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"},
		Default = "Melee",
		Flag = "AutoStats_Type",
		Callback = function(val) end
	})

	CombatSection:AddToggle({
		Name = "Anti Knockback",
		Default = false,
		Flag = "AntiKnockback",
		Callback = function(state)
			Functions:ToggleAntiKnockback(state)
		end
	})

	CombatSection:AddToggle({
		Name = "Auto Respawn",
		Default = false,
		Flag = "AutoRespawn",
		Callback = function(state)
			if state then
				Connections:StartLoop("AutoRespawn", 2, function()
					if not Hub.Flags.AutoRespawn then
						Connections:StopLoop("AutoRespawn")
						return
					end
					Functions:AutoRespawn()
				end)
			else
				Connections:StopLoop("AutoRespawn")
			end
		end
	})

	-- ========================
	-- TAB 3: Teleports
	-- ========================
	local TeleportTab = Window:CreateTab({
		Name = "Teleports",
		Icon = "📍"
	})

	-- Island teleports
	local IslandSection = TeleportTab:CreateSection("Islands")

	local islands = {
		{name = "Starter Island", pos = CFrame.new(0, 40, 0)},
		{name = "Pirate Village", pos = CFrame.new(-968, 40, 1150)},
		{name = "Desert Island", pos = CFrame.new(902, 40, 3392)},
		{name = "Snow Island", pos = CFrame.new(1347, 40, -6185)},
		{name = "Marine Fortress", pos = CFrame.new(-5653, 40, 1811)},
		{name = "Skylands", pos = CFrame.new(-4977, 800, -590)},
		{name = "Prison", pos = CFrame.new(5591, 40, 763)},
		{name = "Colosseum", pos = CFrame.new(-1573, 40, 2944)},
		{name = "Magma Village", pos = CFrame.new(-5222, 40, 8746)},
		{name = "Underwater City", pos = CFrame.new(3879, -50, -1937)},
		{name = "Fountain City", pos = CFrame.new(6200, 40, 1572)},
		{name = "Jungle", pos = CFrame.new(-1250, 40, -1750)},
		{name = "Frozen Village", pos = CFrame.new(1112, 40, -6936)},
		{name = "Ice Castle", pos = CFrame.new(5502, 40, -6313)},
	}

	for _, island in ipairs(islands) do
		IslandSection:AddButton({
			Name = "TP: " .. island.name,
			Callback = function()
				Functions:TeleportTo(island.pos)
				Functions:Notify("Teleport", "Teleported to " .. island.name)
			end
		})
	end

	-- NPC teleports
	local NPCSection = TeleportTab:CreateSection("NPCs & Shops")

	local npcLocations = {
		{name = "Blox Fruit Dealer", pos = CFrame.new(-482, 15, -1096)},
		{name = "Sword Dealer", pos = CFrame.new(-488, 15, -1090)},
		{name = "Ability Teacher", pos = CFrame.new(-460, 15, -1090)},
		{name = "Master of Enhancement", pos = CFrame.new(-645, 7, -999)},
		{name = "Marine Recruiter", pos = CFrame.new(-5653, 40, 1811)},
		{name = "Pirate Recruiter", pos = CFrame.new(-968, 40, 1150)},
		{name = "Bounty/Honor Expert", pos = CFrame.new(-460, 15, -1086)},
	}

	for _, npc in ipairs(npcLocations) do
		NPCSection:AddButton({
			Name = "TP: " .. npc.name,
			Callback = function()
				Functions:TeleportTo(npc.pos)
				Functions:Notify("Teleport", "Teleported to " .. npc.name)
			end
		})
	end

	-- ========================
	-- TAB 4: Fruits
	-- ========================
	local FruitTab = Window:CreateTab({
		Name = "Fruits",
		Icon = "🍎"
	})

	local FruitSection = FruitTab:CreateSection("Fruit Features")

	FruitSection:AddToggle({
		Name = "Auto Collect Fruits",
		Default = false,
		Flag = "AutoCollectFruits",
		Callback = function(state)
			if state then
				Connections:StartLoop("AutoCollectFruits", 0.5, function()
					if not Hub.Flags.AutoCollectFruits then
						Connections:StopLoop("AutoCollectFruits")
						return
					end
					for _, v in ipairs(workspace:GetDescendants()) do
						if v:IsA("Tool") and v:FindFirstChild("Fruit") then
							local root = Functions:GetHumanoidRootPart()
							if root then
								root.CFrame = v.Handle.CFrame
								task.wait(0.1)
								Functions:Click()
							end
						end
					end
				end)
				Functions:Notify("Fruits", "Auto Collect enabled!")
			else
				Connections:StopLoop("AutoCollectFruits")
			end
		end
	})

	FruitSection:AddToggle({
		Name = "Auto Store Fruits",
		Default = false,
		Flag = "AutoStoreFruits",
		Callback = function(state) end
	})

	FruitSection:AddToggle({
		Name = "Fruit Notifier",
		Default = false,
		Flag = "FruitNotifier_Enabled",
		Callback = function(state)
			if state then
				Connections:StartLoop("FruitNotifier", 10, function()
					if not Hub.Flags.FruitNotifier_Enabled then
						Connections:StopLoop("FruitNotifier")
						return
					end
					for _, v in ipairs(workspace:GetDescendants()) do
						if v:IsA("Tool") and v:FindFirstChild("Fruit") then
							Functions:Notify("🍎 Fruit Spawned!", v.Name .. " has spawned!", 5)
						end
					end
				end)
			else
				Connections:StopLoop("FruitNotifier")
			end
		end
	})

	-- ========================
	-- TAB 5: Haki & Abilities
	-- ========================
	local HakiTab = Window:CreateTab({
		Name = "Haki",
		Icon = "💪"
	})

	local HakiSection = HakiTab:CreateSection("Haki")
	HakiSection:AddToggle({
		Name = "Auto Buso Haki",
		Default = false,
		Flag = "AutoBusoHaki",
		Callback = function(state) end
	})

	HakiSection:AddToggle({
		Name = "Auto Ken Haki",
		Default = false,
		Flag = "AutoKenHaki",
		Callback = function(state) end
	})

	HakiSection:AddToggle({
		Name = "Auto Buy Buso",
		Default = false,
		Flag = "AutoBuyBuso",
		Callback = function(state) end
	})

	HakiSection:AddToggle({
		Name = "Auto Buy Ken",
		Default = false,
		Flag = "AutoBuyKen",
		Callback = function(state) end
	})

	local AbilitiesSection = HakiTab:CreateSection("Abilities")
	AbilitiesSection:AddToggle({
		Name = "Auto Buy Geppo",
		Default = false,
		Flag = "AutoBuyGeppo",
		Callback = function(state) end
	})

	AbilitiesSection:AddToggle({
		Name = "Auto Buy Soru",
		Default = false,
		Flag = "AutoBuySoru",
		Callback = function(state) end
	})

	-- ========================
	-- TAB 6: Visual
	-- ========================
	local VisualTab = Window:CreateTab({
		Name = "Visual",
		Icon = "👁️"
	})

	local ESPSection = VisualTab:CreateSection("ESP")
	ESPSection:AddToggle({
		Name = "Player ESP",
		Default = false,
		Flag = "ESP_Players",
		Callback = function(state) end
	})

	ESPSection:AddToggle({
		Name = "NPC ESP",
		Default = false,
		Flag = "ESP_NPCs",
		Callback = function(state) end
	})

	ESPSection:AddToggle({
		Name = "Fruit ESP",
		Default = false,
		Flag = "ESP_Fruits",
		Callback = function(state) end
	})

	ESPSection:AddToggle({
		Name = "Chest ESP",
		Default = false,
		Flag = "ESP_Chests",
		Callback = function(state) end
	})

	local WorldSection = VisualTab:CreateSection("World")
	WorldSection:AddToggle({
		Name = "Full Bright",
		Default = false,
		Flag = "FullBright",
		Callback = function(state)
			if state then
				game:GetService("Lighting").Brightness = 3
				game:GetService("Lighting").ClockTime = 14
				game:GetService("Lighting").FogEnd = 100000
			else
				game:GetService("Lighting").Brightness = 1
				game:GetService("Lighting").ClockTime = 14
				game:GetService("Lighting").FogEnd = 500
			end
		end
	})

	WorldSection:AddToggle({
		Name = "No Fog",
		Default = false,
		Flag = "NoFog",
		Callback = function(state)
			game:GetService("Lighting").FogEnd = state and 100000 or 500
		end
	})

	WorldSection:AddSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Default = 70,
		Suffix = "°",
		Flag = "FOV",
		Callback = function(val)
			workspace.CurrentCamera.FieldOfView = val
		end
	})

	-- ========================
	-- TAB 7: Settings
	-- ========================
	local SettingsTab = Window:CreateTab({
		Name = "Settings",
		Icon = "⚙️"
	})

	local HubSection = SettingsTab:CreateSection("Hub Settings")

	HubSection:AddButton({
		Name = "Save Settings",
		Callback = function()
			Settings:SaveFlags(Hub)
			Functions:Notify("Settings", "Configuration saved!")
		end
	})

	HubSection:AddButton({
		Name = "Reset Settings",
		Callback = function()
			Functions:Notify("Settings", "Settings reset! Rejoin to fully apply.")
			-- basic reset
			for k in pairs(Hub.Flags) do
				Hub.Flags[k] = false
			end
			Connections:StopAllLoops()
		end
	})

	HubSection:AddButton({
		Name = "Rejoin Server",
		Callback = function()
			Functions:Notify("Server", "Rejoining...")
			Functions:Rejoin()
		end
	})

	HubSection:AddButton({
		Name = "Server Hop",
		Callback = function()
			Functions:Notify("Server", "Hopping to new server...")
			Functions:ServerHop()
		end
	})

	HubSection:AddButton({
		Name = "Destroy UI",
		Callback = function()
			Connections:StopAllLoops()
			Settings:SaveFlags(Hub)
			Window:Destroy()
			Functions:Notify("Cosmic", "UI Destroyed. Thanks for using Cosmic Hub!")
		end
	})

	local InfoSection = SettingsTab:CreateSection("Info")
	InfoSection:AddLabel({
		Text = "Cosmic Hub v1.0.0"
	})
	InfoSection:AddLabel({
		Text = "Game: Blox Fruits | Sea 1"
	})
	InfoSection:AddLabel({
		Text = "Executor: Kaitun"
	})
	InfoSection:AddLabel({
		Text = "Made with ❤️ by Cosmic Team"
	})

	--// Store UI reference
	UI.Window = Window
	UI.Flags = Window:GetFlags()

	--// Welcome notification
	task.delay(1, function()
		Window:Notification({
			Title = "🚀 Cosmic Hub",
			Content = "Successfully loaded! Welcome!",
			Duration = 5
		})
	end)

	return UI
end
