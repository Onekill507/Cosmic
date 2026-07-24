--[[
	COSMIC HUB — Core Functions Module
	Shared utilities used across all game modules.
]]
return function(Hub)
	local Functions = {}
	local Env = Hub.Environment
	local Services = Env.Services

	local Players = Services.Players
	local LocalPlayer = Env.LocalPlayer
	local ReplicatedStorage = Services.ReplicatedStorage
	local VirtualInputManager = Services.VirtualInputManager
	local VirtualUser = Services.VirtualUser
	local RunService = Services.RunService
	local UserInputService = Services.UserInputService
	local TweenService = Services.TweenService
	local TeleportService = Services.TeleportService

	--// Player Utilities
	function Functions:GetCharacter()
		return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	end

	function Functions:GetHumanoid()
		local char = self:GetCharacter()
		if char then
			return char:FindFirstChildOfClass("Humanoid")
		end
		return nil
	end

	function Functions:GetHumanoidRootPart()
		local char = self:GetCharacter()
		if char then
			return char:FindFirstChild("HumanoidRootPart")
		end
		return nil
	end

	function Functions:IsAlive()
		local humanoid = self:GetHumanoid()
		return humanoid and humanoid.Health > 0
	end

	function Functions:GetMagnitude(target)
		local root = self:GetHumanoidRootPart()
		if root and target then
			local targetPos = target.Position
			return (root.Position - targetPos).Magnitude
		end
		return math.huge
	end

	--// Teleport
	function Functions:TeleportTo(cframe)
		local root = self:GetHumanoidRootPart()
		if root then
			root.CFrame = cframe
		end
	end

	function Functions:TeleportToPosition(position)
		local root = self:GetHumanoidRootPart()
		if root then
			root.CFrame = CFrame.new(position)
		end
	end

	--// Tween Movement
	function Functions:TweenTo(targetCFrame, speed)
		local root = self:GetHumanoidRootPart()
		if not root then return end

		local distance = (root.Position - targetCFrame.Position).Magnitude
		local tweenTime = distance / (speed or 300)

		local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {
			CFrame = targetCFrame
		})
		tween:Play()
		tween.Completed:Wait()
	end

	--// Click / Attack
	function Functions:Click()
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		task.wait()
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
	end

	function Functions:HoldClick(duration)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		task.wait(duration)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
	end

	--// Key Press
	function Functions:PressKey(key)
		keypress(key)
		task.wait(0.05)
		keyrelease(key)
	end

	--// Equip Tool
	function Functions:EquipTool(toolName)
		local char = self:GetCharacter()
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == toolName then
					local humanoid = self:GetHumanoid()
					if humanoid then
						humanoid:EquipTool(tool)
						return true
					end
				end
			end
		end
		return false
	end

	function Functions:GetCurrentTool()
		local char = self:GetCharacter()
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					return tool
				end
			end
		end
		return nil
	end

	--// Nearest Entity
	function Functions:GetNearestEnemy(range, ignoreFriendly)
		local root = self:GetHumanoidRootPart()
		if not root then return nil end

		local nearest = nil
		local nearestDistance = range or math.huge

		for _, player in ipairs(Players:GetPlayers()) do
			if player == LocalPlayer then continue end
			local char = player.Character
			if not char then continue end

			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			-- Friendly check for teams
			if ignoreFriendly and player.Team == LocalPlayer.Team then continue end

			local distance = (root.Position - hrp.Position).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearest = {Player = player, Character = char, Humanoid = humanoid, RootPart = hrp, Distance = distance}
			end
		end

		return nearest
	end

	--// Nearest NPC
	function Functions:GetNearestNPC(range)
		local root = self:GetHumanoidRootPart()
		if not root then return nil end

		local nearest = nil
		local nearestDistance = range or math.huge

		for _, npc in ipairs(workspace:GetDescendants()) do
			if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
				local humanoid = npc.Humanoid
				if humanoid.Health <= 0 then continue end

				local hrp = npc.HumanoidRootPart
				local distance = (root.Position - hrp.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearest = {Model = npc, Humanoid = humanoid, RootPart = hrp, Distance = distance}
				end
			end
		end

		return nearest
	end

	--// Server Hop
	function Functions:ServerHop()
		local servers = {}
		local HttpService = game:GetService("HttpService")
		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.GameId .. "/servers/Public?sortOrder=Asc&limit=100"))
		end)
		if success and result and result.data then
			for _, server in ipairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server.id)
				end
			end
			if #servers > 0 then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
			end
		end
	end

	--// Rejoin
	function Functions:Rejoin()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end

	--// WalkSpeed / JumpPower
	function Functions:SetWalkSpeed(speed)
		local humanoid = self:GetHumanoid()
		if humanoid then
			humanoid.WalkSpeed = speed
		end
	end

	function Functions:SetJumpPower(power)
		local humanoid = self:GetHumanoid()
		if humanoid then
			humanoid.JumpPower = power
		end
	end

	--// Bring / Pull entity
	function Functions:BringEntity(rootPart)
		local myRoot = self:GetHumanoidRootPart()
		if myRoot and rootPart then
			rootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
		end
	end

	--// Safe Zone detection
	function Functions:InSafeZone()
		local root = self:GetHumanoidRootPart()
		if not root then return false end

		-- Blox Fruits safe zones check (rough)
		local safeZones = workspace:FindFirstChild("SafeZone", true)
		if safeZones then return true end

		-- Check distance from center islands
		local spawnPoints = {
			Vector3.new(0, 20, 0),   -- Starter Island
			Vector3.new(-968, 20, 1150), -- Pirate Island
			Vector3.new(-5653, 20, 1811), -- Marine Island
		}

		for _, spawn in ipairs(spawnPoints) do
			if (root.Position - spawn).Magnitude < 100 then
				return true
			end
		end

		return false
	end

	--// Find Item in world
	function Functions:FindItem(itemName)
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower():find(itemName:lower()) then
				return v
			end
			if v:IsA("Tool") and v.Name:lower():find(itemName:lower()) then
				return v
			end
		end
		return nil
	end

	--// Notification wrapper
	function Functions:Notify(title, msg, dur)
		Hub:Notify(title or "Cosmic", msg or "", dur or 3)
	end

	--// Get Quest NPC by name
	function Functions:GetQuestNPC(npcName)
		for _, v in ipairs(workspace:GetDescendants()) do
			if (v:IsA("Model") or v:IsA("Part")) and v.Name:lower():find(npcName:lower()) then
				if v:FindFirstChild("HumanoidRootPart") then
					return v.HumanoidRootPart
				elseif v:IsA("BasePart") then
					return v
				end
			end
		end
		return nil
	end

	--// Knockback prevention (for farming)
	local antiKnockbackConn = nil
	function Functions:ToggleAntiKnockback(state)
		if state then
			if not antiKnockbackConn then
				local root = self:GetHumanoidRootPart()
				if root then
					root.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
				end
				antiKnockbackConn = LocalPlayer.CharacterAdded:Connect(function(char)
					local hrp = char:WaitForChild("HumanoidRootPart")
					hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
				end)
			end
		else
			if antiKnockbackConn then
				antiKnockbackConn:Disconnect()
				antiKnockbackConn = nil
			end
			local root = self:GetHumanoidRootPart()
			if root then
				root.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 1, 1)
			end
		end
	end

	--// Auto Respawn
	function Functions:AutoRespawn()
		local humanoid = self:GetHumanoid()
		if humanoid and humanoid.Health <= 0 then
			task.wait(2)
			-- Trigger respawn button
			pcall(function()
				local gui = LocalPlayer.PlayerGui
				if gui then
					local deathScreen = gui:FindFirstChild("deathScreen", true)
					if deathScreen then
						for _, btn in ipairs(deathScreen:GetDescendants()) do
							if btn:IsA("TextButton") and btn.Name:lower():find("respawn") then
								btn:Invoke()
							end
						end
					end
				end
			end)
		end
	end

	Hub.Modules["Functions"] = Functions

	return Functions
end
