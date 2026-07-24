--[[
	██████╗  ██████╗ ███████╗███╗   ███╗██╗ ██████╗
	██╔════╝██╔═══██╗██╔════╝████╗ ████║██║██╔════╝
	██║     ██║   ██║███████╗██╔████╔██║██║██║
	██║     ██║   ██║╚════██║██║╚██╔╝██║██║██║
	╚██████╗╚██████╔╝███████║██║ ╚═╝ ██║██║╚██████╗
	 ╚═════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝ ╚═════╝

	COSMIC HUB — Blox Fruits | Sea 1 | Kaitun
	Launcher v1.0.0
	License: Cosmic Network
--]]

local Cosmic = {}
Cosmic.__index = Cosmic

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui") or game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

--// Constants
local PLACE_ID = game.PlaceId
local GAME_ID = game.GameId
local LOCAL_PLAYER = Players.LocalPlayer
local CURRENT_VERSION = "1.0.0"
local GITHUB_RAW = "https://raw.githubusercontent.com/Onekill507/Cosmic/refs/heads/main/"

--// Anti-Cheat Bypass
local function setupAntiDetection()
	-- Hook namecall for common detections
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		if method == "Kick" or method == "kick" then
			return nil
		end
		if method == "IsStudio" then
			return true
		end
		if typeof(self) == "Instance" and self:IsA("RemoteEvent") then
			if tostring(self) == "Detected" or tostring(self) == "Ban" then
				return nil
			end
		end
		return oldNamecall(self, ...)
	end)

	-- Protect from detection remotes
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
			local name = string.lower(v.Name)
			if name:find("detect") or name:find("anticheat") or name:find("ban") then
				pcall(function()
					v.Name = "COSMIC_" .. v.Name
				end)
			end
		end
	end
end

--// Core Functions
function Cosmic.new()
	local self = setmetatable({}, Cosmic)
	self.Modules = {}
	self.Loaded = false
	self.UI = nil
	self.Flags = {}
	self.Connections = {}
	self.Environment = {
		Services = {
			ReplicatedStorage = ReplicatedStorage,
			Players = Players,
			VirtualInputManager = VirtualInputManager,
			VirtualUser = VirtualUser,
			HttpService = HttpService,
			RunService = RunService,
			UserInputService = UserInputService,
			TweenService = TweenService,
			TeleportService = TeleportService,
			MarketplaceService = MarketplaceService,
			Lighting = Lighting
		},
		LocalPlayer = LOCAL_PLAYER,
		PlaceId = PLACE_ID,
		GameId = GAME_ID
	}
	return self
end

function Cosmic:Import(path)
	local success, module = pcall(function()
		return loadstring(game:HttpGet(GITHUB_RAW .. path))()
	end)
	if not success then
		warn("[COSMIC] Failed to import: " .. path .. " | " .. tostring(module))
		return nil
	end
	return module
end

function Cosmic:LoadLibrary(name)
	if self.Modules[name] then
		return self.Modules[name]
	end

	local lib = self:Import("CosmicHub/Library/" .. name .. ".lua")
	if lib then
		self.Modules[name] = lib
		print("[COSMIC] Library loaded: " .. name)
	end
	return lib
end

function Cosmic:LoadModule(modulePath)
	local module = self:Import("CosmicHub/" .. modulePath .. ".lua")
	if module then
		local moduleName = modulePath:match("([^/]+)$")
		self.Modules[moduleName] = module
		print("[COSMIC] Module loaded: " .. moduleName)
	end
	return module
end

function Cosmic:Start()
	print("========================================")
	print("   COSMIC HUB — Starting Initialization")
	print("   Game: Blox Fruits | Sea 1 (Kaitun)")
	print("   Version: " .. CURRENT_VERSION)
	print("========================================")

	-- Setup anti-detection
	setupAntiDetection()

	-- Wait for game to fully load
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	task.wait(2)

	-- Load Fluent UI Library
	local Fluent = self:LoadLibrary("Fluent")
	if not Fluent then
		warn("[COSMIC] FATAL: Fluent library failed to load!")
		return
	end

	-- Load Core Modules
	self:LoadModule("Core/Functions")
	self:LoadModule("Core/Settings")
	self:LoadModule("Core/Connections")

	-- Build UI
	local UI = self:LoadModule("UI/Main")
	if UI and Fluent then
		self.UI = UI:Build(self, Fluent)
	end

	-- Load Game Specific Modules
	self:LoadModule("Game/Init")

	-- Finalize
	self.Loaded = true
	print("[COSMIC] Hub fully loaded and ready!")

	-- Auto-execute saved settings
	local Settings = self.Modules["Settings"]
	if Settings then
		Settings:RestoreFlags(self)
	end
end

function Cosmic:CreateConnection(signal, callback)
	local conn = signal:Connect(callback)
	table.insert(self.Connections, conn)
	return conn
end

function Cosmic:Cleanup()
	for _, conn in ipairs(self.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	self.Connections = {}
	self.Modules = {}
	if self.UI and self.UI.Destroy then
		self.UI:Destroy()
	end
	self.Loaded = false
	print("[COSMIC] Cleanup complete")
end

--// Notification System
function Cosmic:Notify(title, content, duration)
	local Fluent = self.Modules["Fluent"]
	if Fluent and Fluent.Notification then
		Fluent.Notification({
			Title = title or "Cosmic",
			Content = content or "",
			Duration = duration or 5
		})
	end
end

--// Initialize
local Hub = Cosmic.new()
Hub:Start()

return Hub
