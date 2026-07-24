-- Cosmic Hub for Blox Fruits
-- Full-featured UI Hub using Fluent UI Library (Local Client-Side Luau)
-- Made for Blox Fruits | Version 1.0

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create the main window
local Window = Fluent:CreateWindow({
    Title = "Cosmic",
    SubTitle = "Blox Fruits Hub • v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tab definitions with Lucide icons
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farming = Window:AddTab({ Title = "Farming", Icon = "sword" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "apple" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "shield" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "sliders" })
}

local Options = Fluent.Options

-- ============================================
-- MAIN TAB
-- ============================================
do
    Tabs.Main:AddParagraph({
        Title = "Welcome to Cosmic",
        Content = "The ultimate Blox Fruits hub.\nModern • Powerful • Reliable"
    })

    Tabs.Main:AddButton({
        Title = "Join Discord",
        Description = "Get updates & support",
        Callback = function()
            setclipboard("https://discord.gg/cosmic")
            Fluent:Notify({
                Title = "Cosmic",
                Content = "Discord link copied to clipboard!",
                Duration = 4
            })
        end
    })

    Tabs.Main:AddButton({
        Title = "Rejoin Server",
        Description = "Instant rejoin current server",
        Callback = function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    })

    Tabs.Main:AddToggle("AutoSave", {
        Title = "Auto Save Config",
        Description = "Automatically save your settings",
        Default = true
    })

    Tabs.Main:AddKeybind("MenuKey", {
        Title = "Menu Toggle Key",
        Mode = "Toggle",
        Default = "LeftControl",
        Callback = function(Value)
            Window:Minimize()
        end
    })
end

-- ============================================
-- FARMING TAB
-- ============================================
do
    -- Auto Farm Section
    Tabs.Farming:AddSection("Auto Farm")

    Tabs.Farming:AddToggle("AutoFarmLevel", {
        Title = "Auto Farm Level",
        Description = "Automatically farm enemies for XP",
        Default = false
    }):OnChanged(function()
        if Options.AutoFarmLevel.Value then
            Fluent:Notify({ Title = "Cosmic", Content = "Level farming started!", Duration = 3 })
        end
    end)

    Tabs.Farming:AddToggle("AutoFarmBounty", {
        Title = "Auto Farm Bounty",
        Description = "Farm players for bounty",
        Default = false
    })

    Tabs.Farming:AddToggle("AutoKillBoss", {
        Title = "Auto Kill Bosses",
        Description = "Automatically kill all bosses",
        Default = false
    })

    Tabs.Farming:AddToggle("AutoCollectFruits", {
        Title = "Auto Collect Fruits",
        Description = "Collect spawned fruits automatically",
        Default = false
    })

    Tabs.Farming:AddToggle("AutoQuest", {
        Title = "Auto Quest",
        Description = "Complete quests automatically",
        Default = false
    })

    Tabs.Farming:AddToggle("AutoRaid", {
        Title = "Auto Raid",
        Description = "Join and complete raids",
        Default = false
    })

    -- Farming Settings
    Tabs.Farming:AddSection("Farming Settings")

    Tabs.Farming:AddDropdown("FarmMode", {
        Title = "Farm Mode",
        Description = "Choose how to farm",
        Values = {"Closest Enemy", "Highest Level", "Specific Enemy", "Safe Farm"},
        Multi = false,
        Default = "Closest Enemy"
    })

    Tabs.Farming:AddSlider("FarmRange", {
        Title = "Farm Range",
        Description = "Distance to attack enemies",
        Default = 50,
        Min = 20,
        Max = 300,
        Rounding = 0,
        Callback = function(Value)
            -- Update range variable
        end
    })

    Tabs.Farming:AddToggle("BringMobs", {
        Title = "Bring Mobs",
        Description = "Teleport mobs to you",
        Default = false
    })

    Tabs.Farming:AddToggle("AutoHaki", {
        Title = "Auto Haki",
        Description = "Automatically activate Haki",
        Default = true
    })
end

-- ============================================
-- PLAYER TAB
-- ============================================
do
    Tabs.Player:AddSection("Stats")

    Tabs.Player:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Default = 16,
        Min = 16,
        Max = 300,
        Rounding = 0,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })

    Tabs.Player:AddSlider("JumpPower", {
        Title = "Jump Power",
        Default = 50,
        Min = 50,
        Max = 250,
        Rounding = 0,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    })

    Tabs.Player:AddToggle("InfiniteJump", {
        Title = "Infinite Jump",
        Default = false,
        Callback = function(Value)
            if Value then
                game:GetService("UserInputService").JumpRequest:Connect(function()
                    if game.Players.LocalPlayer.Character then
                        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end
    })

    Tabs.Player:AddToggle("Noclip", {
        Title = "Noclip",
        Default = false
    })

    Tabs.Player:AddSection("Health & Defense")

    Tabs.Player:AddToggle("AutoHeal", {
        Title = "Auto Heal",
        Description = "Use healing items automatically",
        Default = false
    })

    Tabs.Player:AddToggle("GodMode", {
        Title = "God Mode (Experimental)",
        Default = false
    })

    Tabs.Player:AddToggle("AutoDodge", {
        Title = "Auto Dodge Attacks",
        Default = false
    })

    Tabs.Player:AddSection("Visuals")

    Tabs.Player:AddToggle("ESP", {
        Title = "Player ESP",
        Description = "Highlight players and enemies",
        Default = false
    })

    Tabs.Player:AddToggle("FruitESP", {
        Title = "Fruit ESP",
        Default = false
    })

    Tabs.Player:AddToggle("BossESP", {
        Title = "Boss ESP",
        Default = false
    })
end

-- ============================================
-- TELEPORTS TAB
-- ============================================
do
    Tabs.Teleports:AddSection("Sea 1")

    local sea1Locations = {
        "Starter Island", "Marine Base", "Pirate Village", "Jungle", "Desert", 
        "Snow Island", "Marine Fortress", "Sky Island", "Fountain City"
    }

    Tabs.Teleports:AddDropdown("Sea1TP", {
        Title = "Sea 1 Locations",
        Values = sea1Locations,
        Multi = false,
        Default = "Starter Island",
        Callback = function(Value)
            -- Teleport logic would go here
            Fluent:Notify({ Title = "Cosmic", Content = "Teleporting to " .. Value, Duration = 2 })
        end
    })

    Tabs.Teleports:AddSection("Sea 2")

    local sea2Locations = {
        "Colosseum", "Magma Village", "Underwater City", "Fountain City", 
        "Dressrosa", "Zou", "Whole Cake Island", "Flower Capital"
    }

    Tabs.Teleports:AddDropdown("Sea2TP", {
        Title = "Sea 2 Locations",
        Values = sea2Locations,
        Multi = false,
        Default = "Colosseum",
        Callback = function(Value)
            Fluent:Notify({ Title = "Cosmic", Content = "Teleporting to " .. Value, Duration = 2 })
        end
    })

    Tabs.Teleports:AddSection("Sea 3")

    local sea3Locations = {
        "Port Town", "Hydra Island", "Great Tree", "Floating Turtle", 
        "Castle on the Sea", "Mansion", "Tiki Outpost", "Mystic Island"
    }

    Tabs.Teleports:AddDropdown("Sea3TP", {
        Title = "Sea 3 Locations",
        Values = sea3Locations,
        Multi = false,
        Default = "Port Town",
        Callback = function(Value)
            Fluent:Notify({ Title = "Cosmic", Content = "Teleporting to " .. Value, Duration = 2 })
        end
    })

    Tabs.Teleports:AddSection("Quick Teleports")

    Tabs.Teleports:AddButton({
        Title = "Teleport to Sea 1",
        Callback = function()
            -- Specific teleport logic
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Sea 2",
        Callback = function()
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Sea 3",
        Callback = function()
        end
    })

    Tabs.Teleports:AddButton({
        Title = "Teleport to Spawn",
        Callback = function()
            Fluent:Notify({ Title = "Cosmic", Content = "Teleporting to spawn...", Duration = 2 })
        end
    })
end

-- ============================================
-- FRUITS TAB
-- ============================================
do
    Tabs.Fruits:AddSection("Fruit Management")

    Tabs.Fruits:AddToggle("AutoEatFruit", {
        Title = "Auto Eat Fruit",
        Description = "Automatically eat best fruit",
        Default = false
    })

    Tabs.Fruits:AddToggle("StoreFruits", {
        Title = "Auto Store Fruits",
        Description = "Store all fruits in inventory",
        Default = false
    })

    Tabs.Fruits:AddToggle("FruitNotifier", {
        Title = "Fruit Notifier",
        Description = "Notify when fruit spawns",
        Default = true
    })

    Tabs.Fruits:AddSection("Fruit Selection")

    local fruitList = {
        "Rocket", "Spin", "Chop", "Spring", "Bomb", "Smoke", "Spike", "Flame", "Ice", "Sand",
        "Dark", "Light", "Rubber", "Barrier", "Magma", "Quake", "Buddha", "Love", "Spider",
        "Sound", "Phoenix", "Rumble", "Paw", "Gravity", "Dough", "Shadow", "Venom", "Control",
        "Dragon", "Leopard", "Kitsune", "T-Rex", "Mammoth", "Portal"
    }

    Tabs.Fruits:AddDropdown("PreferredFruits", {
        Title = "Preferred Fruits",
        Description = "Select fruits you want to prioritize",
        Values = fruitList,
        Multi = true,
        Default = {"Dragon", "Kitsune", "Leopard", "Mammoth"}
    })

    Tabs.Fruits:AddButton({
        Title = "Drop All Fruits",
        Description = "Drop every fruit in inventory",
        Callback = function()
            Fluent:Notify({ Title = "Cosmic", Content = "Dropping all fruits...", Duration = 3 })
        end
    })

    Tabs.Fruits:AddButton({
        Title = "Check Fruit Stock",
        Callback = function()
            Fluent:Notify({ Title = "Cosmic", Content = "Checking fruit stock...", Duration = 3 })
        end
    })
end

-- ============================================
-- COMBAT TAB
-- ============================================
do
    Tabs.Combat:AddSection("Combat Features")

    Tabs.Combat:AddToggle("AutoClick", {
        Title = "Auto Click Attack",
        Default = false
    })

    Tabs.Combat:AddToggle("AutoSkill", {
        Title = "Auto Use Skills",
        Default = false
    })

    Tabs.Combat:AddToggle("KillAura", {
        Title = "Kill Aura",
        Description = "Attack nearby enemies automatically",
        Default = false
    })

    Tabs.Combat:AddToggle("OneShot", {
        Title = "One Shot",
        Description = "Instantly kill enemies (Risky)",
        Default = false
    })

    Tabs.Combat:AddSection("Haki & Abilities")

    Tabs.Combat:AddToggle("AutoObservation", {
        Title = "Auto Observation Haki",
        Default = true
    })

    Tabs.Combat:AddToggle("AutoBuso", {
        Title = "Auto Armament Haki",
        Default = true
    })

    Tabs.Combat:AddToggle("AutoKen", {
        Title = "Auto Observation Ken",
        Default = true
    })

    Tabs.Combat:AddToggle("AutoAwakening", {
        Title = "Auto Fruit Awakening",
        Default = false
    })

    Tabs.Combat:AddSlider("SkillDelay", {
        Title = "Skill Use Delay",
        Default = 0.5,
        Min = 0.1,
        Max = 3,
        Rounding = 1
    })
end

-- ============================================
-- MISC TAB
-- ============================================
do
    Tabs.Misc:AddSection("Quality of Life")

    Tabs.Misc:AddToggle("AutoRedeemCodes", {
        Title = "Auto Redeem Codes",
        Description = "Redeem all available codes",
        Default = false
    })

    Tabs.Misc:AddToggle("AutoJoinTeam", {
        Title = "Auto Join Team",
        Default = false
    })

    Tabs.Misc:AddDropdown("TeamSelect", {
        Title = "Preferred Team",
        Values = {"Pirates", "Marines"},
        Multi = false,
        Default = "Pirates"
    })

    Tabs.Misc:AddToggle("NoCooldown", {
        Title = "No Skill Cooldown",
        Default = false
    })

    Tabs.Misc:AddToggle("InfiniteStamina", {
        Title = "Infinite Stamina",
        Default = false
    })

    Tabs.Misc:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Default = true
    })

    Tabs.Misc:AddSection("Server Utilities")

    Tabs.Misc:AddButton({
        Title = "Server Hop",
        Description = "Hop to a new server",
        Callback = function()
            Fluent:Notify({ Title = "Cosmic", Content = "Hopping servers...", Duration = 3 })
        end
    })

    Tabs.Misc:AddButton({
        Title = "Find Low Server",
        Callback = function()
            Fluent:Notify({ Title = "Cosmic", Content = "Searching for low population server...", Duration = 4 })
        end
    })

    Tabs.Misc:AddToggle("AutoLeaveLowPlayer", {
        Title = "Auto Leave Low Player Servers",
        Default = false
    })
end

-- ============================================
-- SETTINGS TAB
-- ============================================
do
    Tabs.Settings:AddSection("Interface Settings")

    Tabs.Settings:AddDropdown("Theme", {
        Title = "Theme",
        Description = "Change UI appearance",
        Values = {"Dark", "Light", "Darker", "Aqua", "Amethyst", "Rose"},
        Multi = false,
        Default = "Dark",
        Callback = function(Value)
            Fluent:ChangeTheme(Value)
        end
    })

    Tabs.Settings:AddToggle("AcrylicBlur", {
        Title = "Acrylic Blur",
        Description = "Enable background blur effect",
        Default = true,
        Callback = function(Value)
            Window.Acrylic = Value
        end
    })

    Tabs.Settings:AddSlider("Transparency", {
        Title = "UI Transparency",
        Default = 0,
        Min = 0,
        Max = 80,
        Rounding = 0
    })

    Tabs.Settings:AddSection("Configuration")

    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetLibrary(Fluent)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})

    InterfaceManager:SetFolder("CosmicHub")
    SaveManager:SetFolder("CosmicHub/BloxFruits")

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    Tabs.Settings:AddButton({
        Title = "Unload Script",
        Description = "Completely unload Cosmic Hub",
        Callback = function()
            Window:Dialog({
                Title = "Confirm",
                Content = "Are you sure you want to unload Cosmic?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            Fluent:Unload()
                        end
                    },
                    {
                        Title = "Cancel"
                    }
                }
            })
        end
    })

    Tabs.Settings:AddButton({
        Title = "Reset All Settings",
        Callback = function()
            for _, option in pairs(Options) do
                if option.SetValue then
                    option:SetValue(option.Default or false)
                end
            end
            Fluent:Notify({ Title = "Cosmic", Content = "All settings have been reset!", Duration = 3 })
        end
    })
end

-- ============================================
-- INITIALIZATION
-- ============================================

Window:SelectTab(1)

-- Initial notification
Fluent:Notify({
    Title = "Cosmic",
    Content = "Blox Fruits Hub loaded successfully!",
    SubContent = "Enjoy your journey across the seas!",
    Duration = 6
})

-- Auto load config if available
task.spawn(function()
    task.wait(1)
    SaveManager:LoadAutoloadConfig()
end)

-- Anti-AFK (if enabled)
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if Options.AntiAFK and Options.AntiAFK.Value then
        game:GetService("VirtualUser"):ButtonPress(Enum.UserInputType.MouseButton1)
    end
end)

print("[Cosmic] Blox Fruits Hub initialized successfully.")