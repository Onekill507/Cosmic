--[[
	COSMIC HUB — Blox Fruits Sea Events Module
	Handles Sea 1 events: Factory, Ship Raids, Sea Beasts, etc.
]]
return function(Hub)
	local SeaEvents = {}
	local Functions = Hub.Modules["Functions"]
	local Connections = Hub.Modules["Connections"]
	local LocalPlayer = Hub.Environment.LocalPlayer
	local Workspace = game:GetService("Workspace")

	local eventStatus = {
		Factory = false,
		ShipRaid = false,
		SeaBeast = false,
		PirateRaid = false,
	}

	function SeaEvents:DetectFactoryRaid()
		-- Factory raid spawns in Sea 1 near Marine Fortress area
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v.Name:find("Factory") or v.Name:find("Raid") then
				if v:FindFirstChild("HumanoidRootPart") or (v:IsA("BasePart") and v.BrickColor == BrickColor.new("Bright red")) then
					return v
				end
			end
		end
		return nil
	end

	function SeaEvents:DetectSeaBeast()
		-- Sea beasts spawn in water areas
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Model") then
				local name = v.Name:lower()
				if name:find("sea") and name:find("beast") then
					local humanoid = v:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
						return v
					end
				end
			end
		end
		return nil
	end

	function SeaEvents:DetectShipRaid()
		-- Ships that appear for ship raid events
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Model") then
				local name = v.Name:lower()
				if (name:find("ship") or name:find("boat")) and name:find("raid") then
					return v
				end
			end
		end
		return nil
	end

	function SeaEvents:HandleFactoryRaid(factory)
		if not factory or not Functions:IsAlive() then return end

		local root = factory
		if factory:FindFirstChild("HumanoidRootPart") then
			root = factory.HumanoidRootPart
		elseif not factory:IsA("BasePart") then
			-- Find any part
			for _, part in ipairs(factory:GetDescendants()) do
				if part:IsA("BasePart") then
					root = part
					break
				end
			end
		end

		if root then
			Functions:TeleportTo(root.CFrame * CFrame.new(0, 0, 5))
			task.wait(0.1)
			Functions:Click()
		end
	end

	function SeaEvents:HandleSeaBeast(beast)
		if not beast or not Functions:IsAlive() then return end

		local hrp = beast:FindFirstChild("HumanoidRootPart")
		if hrp then
			Functions:TeleportTo(hrp.CFrame * CFrame.new(0, 15, 5))
			task.wait(0.2)
			Functions:Click()
		end
	end

	function SeaEvents:Init(Hub)
		SeaEvents.Hub = Hub

		-- Event detection loop
		Connections:StartLoop("SeaEvents", 3, function()
			if not Functions:IsAlive() then return end

			-- Factory Raid detection
			local factory = SeaEvents:DetectFactoryRaid()
			if factory and not eventStatus.Factory then
				eventStatus.Factory = true
				Functions:Notify("🌊 Event!", "Factory Raid detected!", 5)
			elseif not factory then
				eventStatus.Factory = false
			end

			-- Sea Beast detection
			local seaBeast = SeaEvents:DetectSeaBeast()
			if seaBeast and not eventStatus.SeaBeast then
				eventStatus.SeaBeast = true
				Functions:Notify("🐉 Event!", "Sea Beast spotted!", 5)
			elseif not seaBeast then
				eventStatus.SeaBeast = false
			end

			-- Ship Raid detection
			local shipRaid = SeaEvents:DetectShipRaid()
			if shipRaid and not eventStatus.ShipRaid then
				eventStatus.ShipRaid = true
				Functions:Notify("⛵ Event!", "Ship Raid incoming!", 5)
			elseif not shipRaid then
				eventStatus.ShipRaid = false
			end

			-- Auto-engage sea beast if in water (optional)
			-- Auto-engage factory if nearby
		end)

		-- Sea Beast auto farm hook
		Connections:StartLoop("SeaBeastFarm", 5, function()
			if not Hub.Flags.AutoFarm then return end
			if not Functions:IsAlive() then return end

			local beast = SeaEvents:DetectSeaBeast()
			if beast then
				SeaEvents:HandleSeaBeast(beast)
			end
		end)
	end

	SeaEvents.GetEventStatus = function()
		return eventStatus
	end

	Hub.Modules["SeaEvents"] = SeaEvents

	return SeaEvents
end
