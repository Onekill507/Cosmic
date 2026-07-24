--[[
	COSMIC HUB — Connections Module
	Manages all active RunService connections for loops.
]]
return function(Hub)
	local Connections = {}
	local RunService = Hub.Environment.Services.RunService

	local activeLoops = {}

	function Connections:StartLoop(name, interval, callback)
		if activeLoops[name] then
			self:StopLoop(name)
		end

		local connection
		connection = RunService.Heartbeat:Connect(function(dt)
			if activeLoops[name] and activeLoops[name].lastTick then
				local elapsed = os.clock() - activeLoops[name].lastTick
				if elapsed >= (interval or 0.1) then
					activeLoops[name].lastTick = os.clock()
					pcall(callback)
				end
			elseif activeLoops[name] then
				activeLoops[name].lastTick = os.clock()
			end
		end)

		activeLoops[name] = {
			connection = connection,
			lastTick = os.clock(),
			interval = interval or 0.1
		}

		return connection
	end

	function Connections:StopLoop(name)
		if activeLoops[name] then
			pcall(function()
				activeLoops[name].connection:Disconnect()
			end)
			activeLoops[name] = nil
		end
	end

	function Connections:StopAllLoops()
		for name, _ in pairs(activeLoops) do
			self:StopLoop(name)
		end
	end

	function Connections:IsRunning(name)
		return activeLoops[name] ~= nil
	end

	function Connections:GetRunningLoops()
		local list = {}
		for name in pairs(activeLoops) do
			table.insert(list, name)
		end
		return list
	end

	Hub.Modules["Connections"] = Connections

	return Connections
end
