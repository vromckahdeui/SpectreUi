--[[
    SPECTRE UI LIBRARY - UNIFIED VERSION (Fixed & Hardened)
    Includes: Library, Draggable Toggle, Mobile Scaling, Configs, Sliders.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

local Spectre = {
    Flags = {},
    Connections = {},
    Unloaded = false,
    ToggleGui = nil, 
    AutoLoadEnabled = false,
    CurrentConfigName = "Default",
    Theme = {
        Main = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(22, 22, 22),
        Accent = Color3.fromRGB(120, 80, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        Stroke = Color3.fromRGB(35, 35, 35),  
        Font = Enum.Font.GothamMedium,
        CornerRadius = UDim.new(0, 8)
    }
}

-- Folder Generation
pcall(function()
    if makefolder then
        makefolder("Spectre")
        makefolder("Spectre/Configs")
    end
end)

-- Utility Functions
local function Create(class, props, children)
    local inst = Instance.new(class)
    for i, v in pairs(props or {}) do 
        inst[i] = v 
    end
    for _, child in pairs(children or {}) do 
        child.Parent = inst 
    end
    return inst
end

local function Tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- Main ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "SpectreUI",
    Parent = CoreGui,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

pcall(function()
    if get_hidden_gui or gethui then
        ScreenGui.Parent = get_hidden_gui() or gethui()
    end
end)

-- Mobile Scaling
local UIScale = Create("UIScale", { Parent = ScreenGui, Scale = 1 })

local function UpdateScaling()
    local ViewportSize = workspace.CurrentCamera.ViewportSize
    UIScale.Scale = (ViewportSize.X < 800 or ViewportSize.Y < 600) and 0.78 or 1
end
UpdateScaling()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScaling)

-- Improved Config System (File-based)
function Spectre:SaveConfig(configName)
    local configName = configName or Spectre.CurrentConfigName
    local success = pcall(function()
        if writefile then
            local data = {
                Flags = Spectre.Flags,
                AutoLoad = Spectre.AutoLoadEnabled
            }
            writefile("Spectre/Configs/"..configName..".json", HttpService:JSONEncode(data))
        end
    end)
    if success then 
        Spectre:Notify("Config Saved", "Successfully saved '"..configName.."'", 3) 
    else
        Spectre:Notify("Error", "Failed to save config data", 3)
    end
end

function Spectre:LoadConfig(configName, callbacks)
    local configName = configName or Spectre.CurrentConfigName
    if isfile and isfile("Spectre/Configs/"..configName..".json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("Spectre/Configs/"..configName..".json"))
        end)
        
        if success and data then
            if data.Flags then
                for flag, value in pairs(data.Flags) do
                    Spectre.Flags[flag] = value
                    if callbacks and callbacks[flag] then
                        task.spawn(callbacks[flag], value)
                    end
                end
            end
            Spectre:Notify("Config Loaded", "Successfully loaded '"..configName.."'", 3)
        end
    else
        Spectre:Notify("Notice", "No saved profile configurations found.", 3)
    end
end

-- Notification System
local NotificationContainer = Create("Frame", {
    Parent = ScreenGui,
    Position = UDim2.new(1, -20, 1, -20),
    AnchorPoint = Vector2.new(1, 1),
    Size = UDim2.new(0, 300, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 1000
}, {
    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
})

function Spectre:Notify(title, msg, duration)
    local Frame = Create("Frame", {
        Parent = NotificationContainer,
        Size = UDim2.new(0, 280, 0, 70),
        BackgroundColor3 = Spectre.Theme.Main,
        ClipsDescendants = true,
        BackgroundTransparency = 0.1
    }, {
        Create("UICorner", {CornerRadius = Spectre.Theme.CornerRadius}),
        Create("UIStroke", {Color = Spectre.Theme.Accent, Thickness = 1.5, Transparency = 0.5}),
        Create("Frame", {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = Spectre.Theme.Accent
        }, {Create("UICorner", {CornerRadius = Spectre.Theme.CornerRadius})}),
        Create("TextLabel", {
            Text = title or "Notification",
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 15, 0, 8),
            BackgroundTransparency = 1,
            TextColor3 = Spectre.Theme.Accent,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Create("TextLabel", {
            Text = msg or "",
            Size = UDim2.new(1, -20, 1, -35),
            Position = UDim2.new(0, 15, 0, 28),
            BackgroundTransparency = 1,
            TextColor3 = Spectre.Theme.Text,
            TextSize = 12,
            Font = Spectre.Theme.Font,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
    })
    Tween(Frame, {Size = UDim2.new(0, 280, 0, 70)}, 0.6, Enum.EasingStyle.Back)
    task.delay(duration or 4, function()
        if Frame and Frame.Parent then
            Tween(Frame, {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}, 0.5)
            task.wait(0.5)
            Frame:Destroy()
        end
    end)
end

-- Floating Toggle Button with Smart Mobile Touch Fix
local function CreateToggle(targetGui)
    local ToggleGui = Create("ScreenGui", { Name = "SpectreToggleGui", Parent = CoreGui, ResetOnSpawn = false })

    pcall(function()
        if get_hidden_gui or gethui then 
            ToggleGui.Parent = get_hidden_gui() or gethui() 
        end
    end)
    
    Spectre.ToggleGui = ToggleGui

    local Toggle = Create("ImageButton", {
        Name = "SpectreToggle",
        Parent = ToggleGui,
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        Image = "rbxassetid://126113649238951",
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    }, { Create("UICorner", {CornerRadius = UDim.new(0, 12)}) })

    local dragging = false
    local dragStart, startPos
    local hasMovedPastThreshold = false
    local DRAG_THRESHOLD = 7

    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Toggle.Position
            hasMovedPastThreshold = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if hasMovedPastThreshold or delta.Magnitude > DRAG_THRESHOLD then
                hasMovedPastThreshold = true
                Toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        if not hasMovedPastThreshold then
            targetGui.Enabled = not targetGui.Enabled
        end
    end)
end

-- Main Window Function
function Spectre:Window(title)
    local Window = { CurrentTab = nil, Tabs = {}, RegisteredCallbacks = {} }

    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        Size = UDim2.fromOffset(640, 440),
        Position = UDim2.new(0.5, -320, 0.5, -220),
        BackgroundColor3 = Spectre.Theme.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UICorner", {CornerRadius = Spectre.Theme.CornerRadius}),
        Create("UIStroke", {Color = Spectre.Theme.Stroke, Thickness = 1.2})
    })

    CreateToggle(ScreenGui)

    -- FIXED MAIN FRAME DRAGGING ENGINE (Prevents scrolling conflicts)
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local relativeY = input.Position.Y - MainFrame.AbsolutePosition.Y
            if relativeY >= 0 and relativeY <= 45 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / UIScale.Scale), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / UIScale.Scale))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Spectre.Theme.Secondary,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = Spectre.Theme.CornerRadius}),
        Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Spectre.Theme.Stroke,
            BorderSizePixel = 0
        }),
        Create("TextLabel", {
            Text = title or "SPECTRE",
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, 15), 
            BackgroundTransparency = 1,
            TextColor3 = Spectre.Theme.Accent,
            TextSize = 18,
            Font = Enum.Font.GothamBold
        })
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 1, -80),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, { Create("UIListLayout", {Padding = UDim.new(0, 5)}) })

    local ContentFrame = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundTransparency = 1
    })

    function Window:Tab(name)
        local Tab = { Active = false }
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Spectre.Theme.Main,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Create("TextLabel", {
                Name = "Title",
                Text = name,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Spectre.Theme.TextDark,
                TextSize = 13,
                Font = Spectre.Theme.Font,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        local Page = Create("ScrollingFrame", {
            Parent = ContentFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Spectre.Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        }, {
            Create("UIPadding", {PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)}),
            Create("UIListLayout", {Padding = UDim.new(0, 10)})
        })

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Button.BackgroundTransparency = 1
                Window.CurrentTab.Button.Title.TextColor3 = Spectre.Theme.TextDark
                Window.CurrentTab.Page.Visible = false
            end
            TabButton.BackgroundTransparency = 0
            TabButton.Title.TextColor3 = Spectre.Theme.Accent
            Page.Visible = true
            Window.CurrentTab = {Button = TabButton, Page = Page}
        end)

        if not Window.CurrentTab then
            TabButton.BackgroundTransparency = 0
            TabButton.Title.TextColor3 = Spectre.Theme.Accent
            Page.Visible = true
            Window.CurrentTab = {Button = TabButton, Page = Page}
        end

        function Tab:Toggle(name, flag, default, callback)
            local State = default or false
            if flag then 
                Spectre.Flags[flag] = State 
                Window.RegisteredCallbacks[flag] = callback
            end

            local ToggleFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Spectre.Theme.Secondary,
                BorderSizePixel = 0
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("TextLabel", {
                    Text = name,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Spectre.Theme.Text,
                    TextSize = 13,
                    Font = Spectre.Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("TextButton", {
                    Name = "Switch",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = State and Spectre.Theme.Accent or Spectre.Theme.Main,
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                    Create("Frame", {
                        Name = "Dot",
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                        BackgroundColor3 = Spectre.Theme.Text
                    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })
            })

            local function SetState(newState)
                State = newState
                if flag then Spectre.Flags[flag] = State end
                Tween(ToggleFrame.Switch, {BackgroundColor3 = State and Spectre.Theme.Accent or Spectre.Theme.Main}, 0.2)
                Tween(ToggleFrame.Switch.Dot, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                callback(State)
            end

            ToggleFrame.Switch.MouseButton1Click:Connect(function()
                SetState(not State)
            end)
        end

        function Tab:Button(name, callback)
            local Btn = Create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Spectre.Theme.Secondary,
                Text = name,
                TextColor3 = Spectre.Theme.Text,
                TextSize = 13,
                Font = Spectre.Theme.Font,
                AutoButtonColor = false
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIStroke", {Color = Spectre.Theme.Stroke, Thickness = 1})
            })
            Btn.MouseButton1Click:Connect(callback)
        end

        function Tab:Slider(name, flag, min, max, default, callback)
            local Value = default or min
            if flag then 
                Spectre.Flags[flag] = Value 
                Window.RegisteredCallbacks[flag] = callback
            end

            local SliderFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Spectre.Theme.Secondary,
                BorderSizePixel = 0
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("TextLabel", {
                    Text = name,
                    Size = UDim2.new(1, -100, 0, 25),
                    Position = UDim2.new(0, 12, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Spectre.Theme.Text,
                    TextSize = 13,
                    Font = Spectre.Theme.Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("TextLabel", {
                    Name = "ValLabel",
                    Text = tostring(Value),
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -62, 0, 5),
                    BackgroundTransparency = 1,
                    TextColor3 = Spectre.Theme.Accent,
                    TextSize = 13,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right
                }),
                Create("Frame", {
                    Name = "BarBG",
                    Size = UDim2.new(1, -24, 0, 4),
                    Position = UDim2.new(0, 12, 1, -12),
                    BackgroundColor3 = Spectre.Theme.Main
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                    Create("Frame", {
                        Name = "Fill",
                        Size = UDim2.new((Value - min) / (max - min), 0, 1, 0),
                        BackgroundColor3 = Spectre.Theme.Accent
                    }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                })
            })

            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderFrame.BarBG.AbsolutePosition.X) / SliderFrame.BarBG.AbsoluteSize.X, 0, 1)
                Value = math.floor(min + (max - min) * pos)
                SliderFrame.ValLabel.Text = tostring(Value)
                SliderFrame.BarBG.Fill.Size = UDim2.new(pos, 0, 1, 0)
                if flag then Spectre.Flags[flag] = Value end
                callback(Value)
            end

            local Sliding = false
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                    Sliding = true
                    Update(input) 
                end
            end)
            SliderFrame.InputEnded:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Sliding = false end 
            end)
            SliderFrame.InputChanged:Connect(function(input) 
                if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end 
            end)
        end

        return Tab
    end

    function Window:AddTab(name) return self:Tab(name) end

    -- AUTOMATIC MASTER CORE SPECTRE TAB SETUP
    local CoreTab = Window:AddTab("Spectre")
    
    CoreTab:Button("Destroy UI", function()
        Spectre:Destroy()
    end)
    
    CoreTab:Button("Save Settings Config", function()
        Spectre:SaveConfig()
    end)
    
    CoreTab:Button("Load Settings Config", function()
        Spectre:LoadConfig(Spectre.CurrentConfigName, Window.RegisteredCallbacks)
    end)

    CoreTab:Toggle("Auto-Load Profile", false, function(state)
        Spectre.AutoLoadEnabled = state
        if writefile then
            pcall(function()
                writefile("Spectre/AutoLoad.txt", tostring(state))
            end)
        end
    end)

    -- Handle Startup Auto Load Routine Safely
    task.spawn(function()
        if isfile and isfile("Spectre/AutoLoad.txt") then
            local check = readfile("Spectre/AutoLoad.txt")
            if check == "true" then
                task.wait(0.5)
                Spectre:LoadConfig(Spectre.CurrentConfigName, Window.RegisteredCallbacks)
            end
        end
    end)

    return Window
end

-- Custom Destroy Cleanup Function
function Spectre:Destroy()
    if ScreenGui then ScreenGui:Destroy() end
    if Spectre.ToggleGui then Spectre.ToggleGui:Destroy() end
    
    local OldMain = CoreGui:FindFirstChild("SpectreUI")
    local OldToggle = CoreGui:FindFirstChild("SpectreToggleGui")
    if OldMain then OldMain:Destroy() end
    if OldToggle then OldToggle:Destroy() end
end

return Spectre
