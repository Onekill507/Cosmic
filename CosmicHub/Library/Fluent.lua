--[[
	COSMIC HUB — Fluent UI Library Wrapper
	Forked & adapted for Cosmic Hub
	Credits: dawid-scripts, richie0866, and the Fluent community
]]

local Fluent = {}
Fluent.__index = Fluent

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Constants
local FLUENT_VERSION = "2.1.0"
local TWEEN_SPEED = 0.2
local DEFAULT_ACCENT = Color3.fromRGB(130, 80, 255) -- Cosmic Purple

-- Utility
local function createTween(instance, properties, duration)
	local tween = TweenService:Create(instance, TweenInfo.new(duration or TWEEN_SPEED, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

local function round(num, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- ScreenGui Wrapper
function Fluent.CreateWindow(config)
	local options = config or {}
	local title = options.Title or "Cosmic Hub"
	local subtitle = options.SubTitle or ""
	local tabWidth = options.TabWidth or 160
	local size = options.Size or UDim2.fromOffset(600, 420)
	local theme = options.Theme or "Cosmic"
	local minimizeKey = options.MinimizeKey or Enum.KeyCode.LeftControl

	local FluentWindow = {}
	local flags = {}
	local tabs = {}
	local currentTab = nil

	-- Create ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CosmicHub_UI"
	ScreenGui.Parent = (game:GetService("CoreGui"):FindFirstChild("RobloxGui") or CoreGui)
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	-- Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Size = size
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true

	-- Drop shadow
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Parent = MainFrame
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundTransparency = 1
	Shadow.Position = UDim2.fromScale(0.5, 0.5)
	Shadow.Size = UDim2.new(1, 30, 1, 30)
	Shadow.Image = "rbxassetid://1316045217"
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.7
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	Shadow.ZIndex = 0

	-- Corner rounding
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = MainFrame

	-- Top Bar
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Parent = MainFrame
	TopBar.Size = UDim2.new(1, 0, 0, 36)
	TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	TopBar.BorderSizePixel = 0

	local TopBarCorner = Instance.new("UICorner")
	TopBarCorner.CornerRadius = UDim.new(0, 8)
	TopBarCorner.Parent = TopBar

	-- Title
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Parent = TopBar
	TitleLabel.Position = UDim2.fromOffset(12, 0)
	TitleLabel.Size = UDim2.new(1, -100, 1, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 14
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Window controls
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Name = "Close"
	CloseBtn.Parent = TopBar
	CloseBtn.Position = UDim2.new(1, -36, 0, 8)
	CloseBtn.Size = UDim2.fromOffset(20, 20)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	CloseBtn.Text = ""
	CloseBtn.BorderSizePixel = 0

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(1, 0)
	CloseCorner.Parent = CloseBtn

	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Name = "Minimize"
	MinimizeBtn.Parent = TopBar
	MinimizeBtn.Position = UDim2.new(1, -64, 0, 8)
	MinimizeBtn.Size = UDim2.fromOffset(20, 20)
	MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
	MinimizeBtn.Text = ""
	MinimizeBtn.BorderSizePixel = 0

	local MinCorner = Instance.new("UICorner")
	MinCorner.CornerRadius = UDim.new(1, 0)
	MinCorner.Parent = MinimizeBtn

	local minimized = false
	MinimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			createTween(MainFrame, {Size = UDim2.fromOffset(size.X.Offset, 36)}, 0.3)
		else
			createTween(MainFrame, {Size = size}, 0.3)
		end
	end)

	-- Navigation sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Parent = MainFrame
	Sidebar.Position = UDim2.fromOffset(0, 36)
	Sidebar.Size = UDim2.new(0, tabWidth, 1, -36)
	Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	Sidebar.BorderSizePixel = 0

	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = Sidebar

	-- Tab buttons container
	local TabList = Instance.new("ScrollingFrame")
	TabList.Name = "TabList"
	TabList.Parent = Sidebar
	TabList.Position = UDim2.fromOffset(4, 8)
	TabList.Size = UDim2.new(1, -8, 1, -16)
	TabList.BackgroundTransparency = 1
	TabList.BorderSizePixel = 0
	TabList.ScrollBarThickness = 2
	TabList.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
	TabList.CanvasSize = UDim2.fromOffset(0, 0)

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Parent = TabList
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 2)

	-- Content area
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "Content"
	ContentArea.Parent = MainFrame
	ContentArea.Position = UDim2.fromOffset(tabWidth, 36)
	ContentArea.Size = UDim2.new(1, -tabWidth, 1, -36)
	ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	ContentArea.BorderSizePixel = 0

	local ContentPadding = Instance.new("UIPadding")
	ContentPadding.Parent = ContentArea
	ContentPadding.PaddingLeft = UDim.new(0, 10)
	ContentPadding.PaddingRight = UDim.new(0, 10)
	ContentPadding.PaddingTop = UDim.new(0, 10)

	-- Section containers per tab
	local tabContents = {}

	-- Tab creation function
	function FluentWindow:CreateTab(config)
		local tabName = config.Name
		local tabIcon = config.Icon or ""

		-- Tab button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName
		tabBtn.Parent = TabList
		tabBtn.Size = UDim2.new(1, -4, 0, 32)
		tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		tabBtn.Text = (tabIcon ~= "" and tabIcon .. "  " or "") .. tabName
		tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
		tabBtn.TextSize = 13
		tabBtn.Font = Enum.Font.GothamSemibold
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.BorderSizePixel = 0
		tabBtn.AutoButtonColor = false

		local tabBtnCorner = Instance.new("UICorner")
		tabBtnCorner.CornerRadius = UDim.new(0, 6)
		tabBtnCorner.Parent = tabBtn

		local tabBtnPadding = Instance.new("UIPadding")
		tabBtnPadding.Parent = tabBtn
		tabBtnPadding.PaddingLeft = UDim.new(0, 10)

		-- Tab content frame
		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = tabName .. "_Content"
		tabContent.Parent = ContentArea
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.BorderSizePixel = 0
		tabContent.Visible = false
		tabContent.ScrollBarThickness = 3
		tabContent.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
		tabContent.CanvasSize = UDim2.fromOffset(0, 0)

		local tabLayout = Instance.new("UIListLayout")
		tabLayout.Parent = tabContent
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 8)

		-- Track sections for canvas sizing
		local sectionCount = 0
		local function updateCanvas()
			tabContent.CanvasSize = UDim2.fromOffset(0, sectionCount * 50) -- approximate
		end

		tabBtn.MouseButton1Click:Connect(function()
			if currentTab then
				currentTab.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
				currentTab.btn.TextColor3 = Color3.fromRGB(180, 180, 190)
				currentTab.content.Visible = false
			end
			tabBtn.BackgroundColor3 = DEFAULT_ACCENT
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabContent.Visible = true
			currentTab = {btn = tabBtn, content = tabContent}
		end)

		-- Sections within this tab
		local sections = {}

		local tabObject = {
			Name = tabName,
			Button = tabBtn,
			Content = tabContent,
			Sections = sections,

			CreateSection = function(self, sectionName)
				local sectionFrame = Instance.new("Frame")
				sectionFrame.Name = sectionName .. "_Section"
				sectionFrame.Parent = tabContent
				sectionFrame.Size = UDim2.new(1, 0, 0, 0)
				sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
				sectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
				sectionFrame.BorderSizePixel = 0

				local sectionCorner = Instance.new("UICorner")
				sectionCorner.CornerRadius = UDim.new(0, 6)
				sectionCorner.Parent = sectionFrame

				local sectionPadding = Instance.new("UIPadding")
				sectionPadding.Parent = sectionFrame
				sectionPadding.PaddingLeft = UDim.new(0, 12)
				sectionPadding.PaddingRight = UDim.new(0, 12)
				sectionPadding.PaddingTop = UDim.new(0, 8)
				sectionPadding.PaddingBottom = UDim.new(0, 8)

				-- Section header
				local headerLabel = Instance.new("TextLabel")
				headerLabel.Name = "Header"
				headerLabel.Parent = sectionFrame
				headerLabel.Size = UDim2.new(1, 0, 0, 22)
				headerLabel.BackgroundTransparency = 1
				headerLabel.Text = sectionName
				headerLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
				headerLabel.TextSize = 12
				headerLabel.Font = Enum.Font.GothamBold
				headerLabel.TextXAlignment = Enum.TextXAlignment.Left

				-- Elements container
				local elementList = Instance.new("Frame")
				elementList.Name = "Elements"
				elementList.Parent = sectionFrame
				elementList.Position = UDim2.fromOffset(0, 26)
				elementList.Size = UDim2.new(1, 0, 0, 0)
				elementList.AutomaticSize = Enum.AutomaticSize.Y
				elementList.BackgroundTransparency = 1
				elementList.BorderSizePixel = 0

				local elLayout = Instance.new("UIListLayout")
				elLayout.Parent = elementList
				elLayout.SortOrder = Enum.SortOrder.LayoutOrder
				elLayout.Padding = UDim.new(0, 4)

				sectionCount = sectionCount + 1

				local sectionObj = {
					Frame = sectionFrame,
					Elements = elementList,
					AddToggle = function(_, cfg)
						return FluentWindow:CreateToggle(cfg, elementList, flags)
					end,
					AddButton = function(_, cfg)
						return FluentWindow:CreateButton(cfg, elementList)
					end,
					AddSlider = function(_, cfg)
						return FluentWindow:CreateSlider(cfg, elementList, flags)
					end,
					AddDropdown = function(_, cfg)
						return FluentWindow:CreateDropdown(cfg, elementList, flags)
					end,
					AddLabel = function(_, cfg)
						return FluentWindow:CreateLabel(cfg, elementList)
					end,
					AddKeybind = function(_, cfg)
						return FluentWindow:CreateKeybind(cfg, elementList, flags)
					end,
					AddColorPicker = function(_, cfg)
						return FluentWindow:CreateColorPicker(cfg, elementList, flags)
					end,
					AddTextbox = function(_, cfg)
						return FluentWindow:CreateTextbox(cfg, elementList, flags)
					end,
					AddParagraph = function(_, cfg)
						return FluentWindow:CreateParagraph(cfg, elementList)
					end,
				}
				table.insert(sections, sectionObj)
				return sectionObj
			end
		}

		table.insert(tabs, tabObject)

		-- Auto-select first tab
		if #tabs == 1 then
			tabBtn.BackgroundColor3 = DEFAULT_ACCENT
			tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tabContent.Visible = true
			currentTab = {btn = tabBtn, content = tabContent}
		end

		return tabObject
	end

	-- ========== ELEMENT CREATORS ==========

	function FluentWindow:CreateToggle(config, parent, flagStore)
		local name = config.Name or "Toggle"
		local default = config.Default or false
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Toggle"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 32)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Position = UDim2.fromOffset(0, 4)
		label.Size = UDim2.new(1, -50, 1, -8)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 13
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Name = "Toggle"
		toggleBtn.Parent = frame
		toggleBtn.Position = UDim2.new(1, -44, 0.5, -10)
		toggleBtn.Size = UDim2.fromOffset(44, 20)
		toggleBtn.BackgroundColor3 = default and DEFAULT_ACCENT or Color3.fromRGB(60, 60, 70)
		toggleBtn.Text = ""
		toggleBtn.BorderSizePixel = 0
		toggleBtn.AutoButtonColor = false

		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(1, 0)
		toggleCorner.Parent = toggleBtn

		local toggleDot = Instance.new("Frame")
		toggleDot.Name = "Dot"
		toggleDot.Parent = toggleBtn
		toggleDot.Size = UDim2.fromOffset(16, 16)
		toggleDot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2)
		toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleDot.BorderSizePixel = 0

		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = toggleDot

		local toggled = default
		toggleBtn.MouseButton1Click:Connect(function()
			toggled = not toggled
			flagStore[flag] = toggled

			if toggled then
				createTween(toggleBtn, {BackgroundColor3 = DEFAULT_ACCENT})
				createTween(toggleDot, {Position = UDim2.new(1, -18, 0.5, -8)})
			else
				createTween(toggleBtn, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)})
				createTween(toggleDot, {Position = UDim2.fromOffset(2, 2)})
			end

			callback(toggled)
		end)

		return {
			SetValue = function(_, val)
				toggled = val
				flagStore[flag] = val
				if val then
					toggleBtn.BackgroundColor3 = DEFAULT_ACCENT
					toggleDot.Position = UDim2.new(1, -18, 0.5, -8)
				else
					toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
					toggleDot.Position = UDim2.fromOffset(2, 2)
				end
				callback(val)
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag
		}
	end

	function FluentWindow:CreateButton(config, parent)
		local name = config.Name or "Button"
		local callback = config.Callback or function() end

		local btn = Instance.new("TextButton")
		btn.Name = name .. "_Button"
		btn.Parent = parent
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.BackgroundColor3 = DEFAULT_ACCENT
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 13
		btn.Font = Enum.Font.GothamSemibold
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(callback)

		return { Fire = function() callback() end }
	end

	function FluentWindow:CreateSlider(config, parent, flagStore)
		local name = config.Name or "Slider"
		local minVal = config.Min or 0
		local maxVal = config.Max or 100
		local default = config.Default or minVal
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()
		local suffix = config.Suffix or ""

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Slider"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 44)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Size = UDim2.new(1, 0, 0, 18)
		label.BackgroundTransparency = 1
		label.Text = name .. ": " .. default .. suffix
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local sliderBg = Instance.new("Frame")
		sliderBg.Name = "SliderBg"
		sliderBg.Parent = frame
		sliderBg.Position = UDim2.fromOffset(0, 20)
		sliderBg.Size = UDim2.new(1, 0, 0, 6)
		sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		sliderBg.BorderSizePixel = 0

		local sliderCorner = Instance.new("UICorner")
		sliderCorner.CornerRadius = UDim.new(1, 0)
		sliderCorner.Parent = sliderBg

		local sliderFill = Instance.new("Frame")
		sliderFill.Name = "Fill"
		sliderFill.Parent = sliderBg
		sliderFill.Size = UDim2.fromScale((default - minVal) / (maxVal - minVal), 1)
		sliderFill.BackgroundColor3 = DEFAULT_ACCENT
		sliderFill.BorderSizePixel = 0

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = sliderFill

		local currentValue = default

		local function updateSlider(input)
			local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
			local val = math.floor(minVal + (maxVal - minVal) * pos)
			currentValue = val
			flagStore[flag] = val
			sliderFill.Size = UDim2.fromScale(pos, 1)
			label.Text = name .. ": " .. val .. suffix
			callback(val)
		end

		local dragging = false

		sliderBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSlider(input)
			end
		end)

		return {
			SetValue = function(_, val)
				local clamped = math.clamp(val, minVal, maxVal)
				currentValue = clamped
				flagStore[flag] = clamped
				local scale = (clamped - minVal) / (maxVal - minVal)
				sliderFill.Size = UDim2.fromScale(scale, 1)
				label.Text = name .. ": " .. clamped .. suffix
				callback(clamped)
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag
		}
	end

	function FluentWindow:CreateDropdown(config, parent, flagStore)
		local name = config.Name or "Dropdown"
		local options = config.Options or {}
		local default = config.Default or (options[1] or "")
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Dropdown"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 36)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = false

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Size = UDim2.new(1, 0, 0, 16)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local dropdownBtn = Instance.new("TextButton")
		dropdownBtn.Name = "DropdownBtn"
		dropdownBtn.Parent = frame
		dropdownBtn.Position = UDim2.fromOffset(0, 18)
		dropdownBtn.Size = UDim2.new(1, 0, 0, 28)
		dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
		dropdownBtn.Text = "  " .. default
		dropdownBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
		dropdownBtn.TextSize = 12
		dropdownBtn.Font = Enum.Font.Gotham
		dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
		dropdownBtn.BorderSizePixel = 0
		dropdownBtn.AutoButtonColor = false

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = dropdownBtn

		-- Dropdown list (floating)
		local listFrame = Instance.new("Frame")
		listFrame.Name = "DropdownList"
		listFrame.Parent = frame
		listFrame.Position = UDim2.fromOffset(0, 48)
		listFrame.Size = UDim2.new(1, 0, 0, #options * 26)
		listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		listFrame.BorderSizePixel = 0
		listFrame.Visible = false
		listFrame.ZIndex = 10

		local listCorner = Instance.new("UICorner")
		listCorner.CornerRadius = UDim.new(0, 6)
		listCorner.Parent = listFrame

		local listLayout = Instance.new("UIListLayout")
		listLayout.Parent = listFrame
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder

		for _, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Name = opt
			optBtn.Parent = listFrame
			optBtn.Size = UDim2.new(1, 0, 0, 26)
			optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
			optBtn.Text = opt
			optBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
			optBtn.TextSize = 12
			optBtn.Font = Enum.Font.Gotham
			optBtn.BorderSizePixel = 0
			optBtn.AutoButtonColor = false

			optBtn.MouseButton1Click:Connect(function()
				flagStore[flag] = opt
				dropdownBtn.Text = "  " .. opt
				listFrame.Visible = false
				callback(opt)
			end)
		end

		dropdownBtn.MouseButton1Click:Connect(function()
			listFrame.Visible = not listFrame.Visible
		end)

		return {
			SetValue = function(_, val)
				if table.find(options, val) then
					flagStore[flag] = val
					dropdownBtn.Text = "  " .. val
					callback(val)
				end
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag,
			Options = options
		}
	end

	function FluentWindow:CreateLabel(config, parent)
		local text = config.Text or ""

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Parent = parent
		label.Size = UDim2.new(1, 0, 0, 22)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.fromRGB(180, 180, 190)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true

		return { SetText = function(_, t) label.Text = t end }
	end

	function FluentWindow:CreateKeybind(config, parent, flagStore)
		local name = config.Name or "Keybind"
		local default = config.Default or Enum.KeyCode.F
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Keybind"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 34)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Position = UDim2.fromOffset(0, 4)
		label.Size = UDim2.new(1, -100, 1, -8)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 13
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local keyBtn = Instance.new("TextButton")
		keyBtn.Name = "KeyBtn"
		keyBtn.Parent = frame
		keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
		keyBtn.Size = UDim2.fromOffset(90, 24)
		keyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
		keyBtn.Text = default.Name
		keyBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
		keyBtn.TextSize = 11
		keyBtn.Font = Enum.Font.Gotham
		keyBtn.BorderSizePixel = 0
		keyBtn.AutoButtonColor = false

		local keyCorner = Instance.new("UICorner")
		keyCorner.CornerRadius = UDim.new(0, 6)
		keyCorner.Parent = keyBtn

		local binding = false
		keyBtn.MouseButton1Click:Connect(function()
			binding = true
			keyBtn.Text = "..."
		end)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if binding and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					flagStore[flag] = input.KeyCode
					keyBtn.Text = input.KeyCode.Name
					binding = false
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					-- ignore clicks outside
					binding = false
					keyBtn.Text = flagStore[flag].Name
				end
			elseif not binding and input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == flagStore[flag] then
					callback()
				end
			end
		end)

		return {
			SetValue = function(_, key)
				flagStore[flag] = key
				keyBtn.Text = key.Name
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag
		}
	end

	function FluentWindow:CreateColorPicker(config, parent, flagStore)
		local name = config.Name or "Color"
		local default = config.Default or DEFAULT_ACCENT
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Color"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 34)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Position = UDim2.fromOffset(0, 4)
		label.Size = UDim2.new(1, -40, 1, -8)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 13
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local colorPreview = Instance.new("TextButton")
		colorPreview.Name = "ColorPreview"
		colorPreview.Parent = frame
		colorPreview.Position = UDim2.new(1, -34, 0.5, -10)
		colorPreview.Size = UDim2.fromOffset(34, 20)
		colorPreview.BackgroundColor3 = default
		colorPreview.Text = ""
		colorPreview.BorderSizePixel = 0
		colorPreview.AutoButtonColor = false

		local previewCorner = Instance.new("UICorner")
		previewCorner.CornerRadius = UDim.new(0, 6)
		previewCorner.Parent = colorPreview

		-- Simple color selection via text input approach (real color picker would need more)
		local colors = {
			Color3.fromRGB(255, 60, 60),
			Color3.fromRGB(255, 140, 60),
			Color3.fromRGB(255, 220, 60),
			Color3.fromRGB(60, 255, 90),
			Color3.fromRGB(60, 180, 255),
			Color3.fromRGB(130, 80, 255),
			Color3.fromRGB(255, 80, 200),
			Color3.fromRGB(255, 255, 255),
		}

		local colorIndex = 1
		colorPreview.MouseButton1Click:Connect(function()
			colorIndex = (colorIndex % #colors) + 1
			local col = colors[colorIndex]
			flagStore[flag] = col
			colorPreview.BackgroundColor3 = col
			callback(col)
		end)

		return {
			SetValue = function(_, col)
				flagStore[flag] = col
				colorPreview.BackgroundColor3 = col
				callback(col)
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag
		}
	end

	function FluentWindow:CreateTextbox(config, parent, flagStore)
		local name = config.Name or "Textbox"
		local default = config.Default or ""
		local placeholder = config.Placeholder or "Enter text..."
		local callback = config.Callback or function() end
		local flag = config.Flag or name:gsub("%s+", "_"):lower()

		flagStore[flag] = default

		local frame = Instance.new("Frame")
		frame.Name = name .. "_Textbox"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 34)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local label = Instance.new("TextLabel")
		label.Parent = frame
		label.Size = UDim2.new(1, 0, 0, 16)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
		label.TextSize = 12
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left

		local textBox = Instance.new("TextBox")
		textBox.Name = "Input"
		textBox.Parent = frame
		textBox.Position = UDim2.fromOffset(0, 18)
		textBox.Size = UDim2.new(1, 0, 0, 28)
		textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
		textBox.TextColor3 = Color3.fromRGB(220, 220, 230)
		textBox.PlaceholderText = placeholder
		textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
		textBox.Text = default
		textBox.TextSize = 12
		textBox.Font = Enum.Font.Gotham
		textBox.BorderSizePixel = 0
		textBox.ClearTextOnFocus = false

		local tbCorner = Instance.new("UICorner")
		tbCorner.CornerRadius = UDim.new(0, 6)
		tbCorner.Parent = textBox

		local tbPadding = Instance.new("UIPadding")
		tbPadding.Parent = textBox
		tbPadding.PaddingLeft = UDim.new(0, 8)

		textBox.FocusLost:Connect(function()
			flagStore[flag] = textBox.Text
			callback(textBox.Text)
		end)

		return {
			SetValue = function(_, val)
				flagStore[flag] = val
				textBox.Text = val
				callback(val)
			end,
			GetValue = function() return flagStore[flag] end,
			Flag = flag
		}
	end

	function FluentWindow:CreateParagraph(config, parent)
		local title = config.Title or ""
		local content = config.Content or ""

		local frame = Instance.new("Frame")
		frame.Name = "Paragraph"
		frame.Parent = parent
		frame.Size = UDim2.new(1, 0, 0, 44)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Parent = frame
		titleLabel.Size = UDim2.new(1, 0, 0, 18)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
		titleLabel.TextSize = 12
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left

		local contentLabel = Instance.new("TextLabel")
		contentLabel.Parent = frame
		contentLabel.Position = UDim2.fromOffset(0, 20)
		contentLabel.Size = UDim2.new(1, 0, 0, 24)
		contentLabel.BackgroundTransparency = 1
		contentLabel.Text = content
		contentLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
		contentLabel.TextSize = 11
		contentLabel.Font = Enum.Font.Gotham
		contentLabel.TextXAlignment = Enum.TextXAlignment.Left
		contentLabel.TextWrapped = true

		return {
			SetTitle = function(_, t) titleLabel.Text = t end,
			SetContent = function(_, c) contentLabel.Text = c end
		}
	end

	-- ========== WINDOW METHODS ==========

	function FluentWindow:Notification(config)
		local notifTitle = config.Title or "Cosmic"
		local notifContent = config.Content or ""
		local notifDuration = config.Duration or 5

		local notif = Instance.new("Frame")
		notif.Name = "Notification"
		notif.Parent = ScreenGui
		notif.Position = UDim2.new(1, -10, 0, 10)
		notif.AnchorPoint = Vector2.new(1, 0)
		notif.Size = UDim2.fromOffset(280, 60)
		notif.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		notif.BorderSizePixel = 0
		notif.BackgroundTransparency = 0
		notif.ZIndex = 100

		local notifCorner = Instance.new("UICorner")
		notifCorner.CornerRadius = UDim.new(0, 8)
		notifCorner.Parent = notif

		local accentBar = Instance.new("Frame")
		accentBar.Name = "Accent"
		accentBar.Parent = notif
		accentBar.Size = UDim2.new(0, 4, 1, 0)
		accentBar.BackgroundColor3 = DEFAULT_ACCENT
		accentBar.BorderSizePixel = 0

		local notifTitleLabel = Instance.new("TextLabel")
		notifTitleLabel.Parent = notif
		notifTitleLabel.Position = UDim2.fromOffset(12, 6)
		notifTitleLabel.Size = UDim2.new(1, -16, 0, 18)
		notifTitleLabel.BackgroundTransparency = 1
		notifTitleLabel.Text = notifTitle
		notifTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		notifTitleLabel.TextSize = 13
		notifTitleLabel.Font = Enum.Font.GothamBold
		notifTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

		local notifContentLabel = Instance.new("TextLabel")
		notifContentLabel.Parent = notif
		notifContentLabel.Position = UDim2.fromOffset(12, 26)
		notifContentLabel.Size = UDim2.new(1, -16, 1, -32)
		notifContentLabel.BackgroundTransparency = 1
		notifContentLabel.Text = notifContent
		notifContentLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
		notifContentLabel.TextSize = 11
		notifContentLabel.Font = Enum.Font.Gotham
		notifContentLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Animate in
		notif.Position = UDim2.new(1, 290, 0, 10)
		createTween(notif, {Position = UDim2.new(1, -10, 0, 10)}, 0.3)

		-- Auto dismiss
		task.delay(notifDuration, function()
			if notif and notif.Parent then
				createTween(notif, {Position = UDim2.new(1, 290, 0, 10)}, 0.3)
				task.wait(0.3)
				notif:Destroy()
			end
		end)
	end

	function FluentWindow:Dialog(config)
		-- simple confirmation dialog
		-- placeholder for future
	end

	-- Minimize keybind
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == minimizeKey then
				minimized = not minimized
				if minimized then
					createTween(MainFrame, {Size = UDim2.fromOffset(size.X.Offset, 36)}, 0.3)
				else
					createTween(MainFrame, {Size = size}, 0.3)
				end
			end
		end
	end)

	-- Make window draggable
	local dragging = false
	local dragStart = nil
	local startPos = nil

	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Store everything
	FluentWindow.ScreenGui = ScreenGui
	FluentWindow.MainFrame = MainFrame
	FluentWindow.Tabs = tabs
	FluentWindow.Flags = flags
	FluentWindow.AccentColor = DEFAULT_ACCENT

	-- Global methods
	FluentWindow.Destroy = function()
		ScreenGui:Destroy()
	end

	FluentWindow.SetAccent = function(_, color)
		DEFAULT_ACCENT = color
	end

	FluentWindow.GetFlags = function()
		return flags
	end

	return FluentWindow
end

return Fluent
