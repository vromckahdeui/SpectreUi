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
    Theme = {
        Main = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(22, 22, 22),
        Accent = Color3.fromRGB(120, 80, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        Stroke = Color3.fromRGB(35, 35, 35),  -- Dark grey outer lining
        Font = Enum.Font.GothamMedium,
        CornerRadius = UDim.new(0, 8)
    }
}

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

-- Executor Protection
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
function Spectre:SaveConfig(configName, data)
    local success = pcall(function()
        writefile("Spectre/Configs/"..configName..".json", HttpService:JSONEncode(data))
    end)
    if success then 
        Spectre:Notify("Config Saved", "Successfully saved '"..configName.."'", 3) 
    else
        Spectre:Notify("Error", "Failed to save config", 3)
    end
end

function Spectre:LoadConfig(configName, callback)
    if isfile("Spectre/Configs/"..configName..".json") then
        local data = readfile("Spectre/Configs/"..configName..".json")
        callback(HttpService:JSONDecode(data))
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
        Tween(Frame, {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1}, 0.5)
        task.wait(0.5)
        Frame:Destroy()
    end)
end

-- Floating Toggle Button
local function CreateToggle(targetGui)
    local ToggleGui = Create("ScreenGui", { Name = "SpectreToggleGui", Parent = CoreGui, ResetOnSpawn = false })

    pcall(function()
        if get_hidden_gui or gethui then 
            ToggleGui.Parent = get_hidden_gui() or gethui() 
        end
    end)

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

    local dragging, dragStart, startPos
    Toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Toggle.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    Toggle.MouseButton1Click:Connect(function()
        targetGui.Enabled = not targetGui.Enabled
    end)
end

-- Main Window Function
function Spectre:Window(title, subtitle)
    local Window = { CurrentTab = nil, Tabs = {} }

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

    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
            Position = UDim2.new(0, 0, 0, 10),
            BackgroundTransparency = 1,
            TextColor3 = Spectre.Theme.Accent,
            TextSize = 18,
            Font = Enum.Font.GothamBold
        }),
        Create("TextLabel", {
            Text = subtitle or "",
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundTransparency = 1,
            TextColor3 = Spectre.Theme.TextDark,
            TextSize = 10,
            Font = Spectre.Theme.Font
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

        function Tab:Toggle(name, default, callback)
            local State = default or false
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

            ToggleFrame.Switch.MouseButton1Click:Connect(function()
                State = not State
                Tween(ToggleFrame.Switch, {BackgroundColor3 = State and Spectre.Theme.Accent or Spectre.Theme.Main}, 0.2)
                Tween(ToggleFrame.Switch.Dot, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                callback(State)
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

        function Tab:Slider(name, min, max, default, callback)
            local Value = default or min
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
                callback(Value)
            end

            local Sliding = false
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                    Sliding = true
                    Update(input) 
                end
            end)
            UserInputService.InputEnded:Connect(function(input) 
                if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end 
            end)
            UserInputService.InputChanged:Connect(function(input) 
                if Sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end 
            end)
        end

        return Tab
    end

    function Window:AddTab(name) return self:Tab(name) end
    return Window
end

-- Simply hand over the library engine back to the loader script
return Spectre
