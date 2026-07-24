--[[
	COSMIC HUB — Universal Game Module
	Provides basic features for unsupported games.
]]
return function(Hub)
	local Universal = {}
	local Functions = Hub.Modules["Functions"]
	local Connections = Hub.Modules["Connections"]
	local LocalPlayer = Hub.Environment.LocalPlayer

	function Universal:Init(Hub)
		Universal.Hub = Hub

		-- Basic features that work in any game

		-- WalkSpeed & JumpPower are already handled in UI callbacks

		-- NoClip is handled in UI callbacks

		-- ESP (basic)
		Connections:StartLoop("UniversalESP", 0.5, function()
			if not Hub.Flags.ESP_Players then return end

			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				if player == LocalPlayer then continue end
				local char = player.Character
				if not char then continue end

				local head = char:FindFirstChild("Head")
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not head or not hrp then continue end

				-- Basic highlight
				local highlight = char:FindFirstChild("CosmicHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "CosmicHighlight"
					highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 60, 60)
					highlight.FillTransparency = 0.5
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0
					highlight.Parent = char
				end
			end

			-- Cleanup highlights for disconnected players
			for _, v in ipairs(workspace:GetDescendants()) do
				if v.Name == "CosmicHighlight" then
					local parent = v.Parent
					if parent and parent:IsA("Model") then
						local player = game:GetService("Players"):GetPlayerFromCharacter(parent)
						if not player then
							v:Destroy()
						end
					end
				end
			end
		end)

		Functions:Notify("Cosmic", "Universal mode loaded. Some features may be limited.", 5)
	end

	function Universal:Cleanup()
		-- Remove all highlights
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.Name == "CosmicHighlight" then
				v:Destroy()
			end
		end
	end

	Hub.Modules["Universal"] = Universal

	return Universal
end
