
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Prevent duplicate interface instances
if CoreGui:FindFirstChild("OperationOneUI") then
    CoreGui.OperationOneUI:Destroy()
end

local Library = {}

-- Framework Core Configuration Variables
local FontStyle = Enum.Font.Code
local AccentColor = Color3.fromRGB(214, 43, 117)
local UI_HIDDEN = false
local DEBOUNCE = false
local OriginalSize = UDim2.new(0, 580, 0, 360)

-- Tab Navigation Registry
local Pages = {}
local TabButtons = {}
local TabOrder = {"Combat", "Visuals", "Players", "Settings"}
local TabAssets = {
    ["Combat"]  = "http://www.roblox.com/asset/?id=7300477598",
    ["Visuals"] = "http://www.roblox.com/asset/?id=7300535052",
    ["Players"] = "http://www.roblox.com/asset/?id=7300480952",
    ["Settings"]= "http://www.roblox.com/asset/?id=7300486042"
}

-- [[ MASTER INITIALIZATION ]] --
local UI = Instance.new("ScreenGui")
UI.Name = "OperationOneUI"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = OriginalSize
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

-- Premium Glowing Outline
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.8
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(110, 110, 110)
UIStroke.Parent = MainFrame

local function StartGlowAnimation()
    local MidGrey = Color3.fromRGB(110, 110, 110)
    local PureWhite = Color3.fromRGB(255, 255, 255)
    local TweenInfoStyle = TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local GlowTween = TweenService:Create(UIStroke, TweenInfoStyle, {Color = PureWhite})
    UIStroke.Color = MidGrey
    GlowTween:Play()
end
coroutine.wrap(StartGlowAnimation)()

-- Title Construction
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "Operation One"
TitleBar.TextColor3 = Color3.fromRGB(180, 180, 180)
TitleBar.Font = FontStyle
TitleBar.TextSize = 13
TitleBar.Parent = MainFrame

-- Minimize Button
local MobileMinimizeBtn = Instance.new("TextButton")
MobileMinimizeBtn.Name = "MobileMinimizeBtn"
MobileMinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MobileMinimizeBtn.Position = UDim2.new(1, -30, 0, 3)
MobileMinimizeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MobileMinimizeBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
MobileMinimizeBtn.Font = Enum.Font.GothamMedium
MobileMinimizeBtn.Text = "—"
MobileMinimizeBtn.TextSize = 10
MobileMinimizeBtn.ZIndex = 5
MobileMinimizeBtn.Parent = MainFrame

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 4)
MinimizeCorner.Parent = MobileMinimizeBtn

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Thickness = 1
MinimizeStroke.Color = Color3.fromRGB(50, 50, 50)
MinimizeStroke.Parent = MobileMinimizeBtn

local TitleLine = Instance.new("Frame")
TitleLine.Size = UDim2.new(1, 0, 0, 1)
TitleLine.Position = UDim2.new(0, 0, 0, 25)
TitleLine.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLine.BorderSizePixel = 0
TitleLine.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 55)
TabContainer.Position = UDim2.new(0, 0, 0, 26)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -15, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -20)
Footer.BackgroundTransparency = 1
Footer.Text = "powered by xoh"
Footer.TextColor3 = Color3.fromRGB(60, 60, 60)
Footer.Font = FontStyle
Footer.TextSize = 11
Footer.TextXAlignment = Enum.TextXAlignment.Right
Footer.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -110)
ContentFrame.Position = UDim2.new(0, 10, 0, 85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Resize Engine
local ResizeGrip = Instance.new("TextButton")
ResizeGrip.Name = "ResizeGrip"
ResizeGrip.Size = UDim2.new(0, 15, 0, 15)
ResizeGrip.Position = UDim2.new(1, -15, 1, -15)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Text = "◢"
ResizeGrip.TextSize = 12
ResizeGrip.TextColor3 = Color3.fromRGB(60, 60, 60)
ResizeGrip.ZIndex = 5
ResizeGrip.Parent = MainFrame

local isResizing = false
local startSize, startMousePos

ResizeGrip.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        startSize = MainFrame.Size
        startMousePos = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isResizing = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startMousePos
        local newWidth = math.clamp(startSize.X.Offset + delta.X, 400, 900)
        local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 280, 650)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        OriginalSize = MainFrame.Size
    end
end)

-- Visibility Control Box
local Prompt = Instance.new("Frame")
Prompt.Name = "RayfieldToggleBox"
Prompt.Parent = UI
Prompt.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Prompt.BackgroundTransparency = 1
Prompt.BorderSizePixel = 0
Prompt.Size = UDim2.new(0, 40, 0, 10)
Prompt.Position = UDim2.new(0.5, -20, 0, -50)
Prompt.Visible = false
Prompt.ZIndex = 100

local PromptStroke = Instance.new("UIStroke")
PromptStroke.Thickness = 1.5
PromptStroke.Color = Color3.fromRGB(60, 60, 60)
PromptStroke.Transparency = 1
PromptStroke.Parent = Prompt

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = Prompt

local PromptTitle = Instance.new("TextLabel")
PromptTitle.Name = "Title"
PromptTitle.Parent = Prompt
PromptTitle.BackgroundTransparency = 1
PromptTitle.Size = UDim2.new(1, 0, 1, 0)
PromptTitle.Text = "SHOW MENU"
PromptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PromptTitle.TextTransparency = 1
PromptTitle.Font = Enum.Font.GothamBold
PromptTitle.TextSize = 11

local Interact = Instance.new("TextButton")
Interact.Name = "Interact"
Interact.Parent = Prompt
Interact.BackgroundTransparency = 1
Interact.Size = UDim2.new(1, 0, 1, 0)
Interact.Text = ""

local function ToggleUI()
    if DEBOUNCE then return end
    DEBOUNCE = true
    UI_HIDDEN = not UI_HIDDEN
    
    if UI_HIDDEN then
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        MainFrame.Visible = false
        Prompt.Visible = true
        TweenService:Create(Prompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 130, 0, 32), Position = UDim2.new(0.5, -65, 0, 0), BackgroundTransparency = 0.05}):Play()
        TweenService:Create(PromptStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
        TweenService:Create(PromptTitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
    else
        TweenService:Create(Prompt, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(0, 40, 0, 10), Position = UDim2.new(0.5, -20, 0, -50), BackgroundTransparency = 1}):Play()
        TweenService:Create(PromptStroke, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
        TweenService:Create(PromptTitle, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
        task.wait(0.2)
        Prompt.Visible = false
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = OriginalSize, BackgroundTransparency = 0}):Play()
    end
    task.wait(0.5)
    DEBOUNCE = false
end

Interact.MouseButton1Click:Connect(function() if UI_HIDDEN then ToggleUI() end end)
MobileMinimizeBtn.MouseButton1Click:Connect(function() if not UI_HIDDEN then ToggleUI() end end)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.K then ToggleUI() end
end)

-- Setup Display Tabs Routing
local TabWidth = 1 / #TabOrder
for i, tabName in ipairs(TabOrder) do
    local Page = Instance.new("Frame")
    Page.Name = tabName .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = (i == 1)
    Page.Parent = ContentFrame
    Pages[tabName] = Page

    local LeftCol = Instance.new("ScrollingFrame")
    LeftCol.Name = "LeftCol"
    LeftCol.Size = UDim2.new(0.48, 0, 1, 0)
    LeftCol.BackgroundTransparency = 1
    LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
    LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LeftCol.ScrollBarThickness = 0
    LeftCol.Parent = Page

    local LeftList = Instance.new("UIListLayout")
    LeftList.Padding = UDim.new(0, 12)
    LeftList.Parent = LeftCol

    local RightCol = LeftCol:Clone()
    RightCol.Name = "RightCol"
    RightCol.Position = UDim2.new(0.52, 0, 0, 0)
    RightCol.Parent = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "Tab"
    TabBtn.Size = UDim2.new(TabWidth, 0, 1, 0)
    TabBtn.Position = UDim2.new((i-1) * TabWidth, 0, 0, 0)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.Parent = TabContainer

    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "TabIcon"
    TabIcon.Size = UDim2.new(0, 24, 0, 24)
    TabIcon.Position = UDim2.new(0.5, -12, 0.2, 0)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = TabAssets[tabName]
    TabIcon.ImageColor3 = (i == 1) and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(130, 130, 130)
    TabIcon.Parent = TabBtn

    local TabText = Instance.new("TextLabel")
    TabText.Name = "TabText"
    TabText.Size = UDim2.new(1, 0, 0, 20)
    TabText.Position = UDim2.new(0, 0, 0.6, 0)
    TabText.BackgroundTransparency = 1
    TabText.Text = tabName
    TabText.TextColor3 = (i == 1) and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(130, 130, 130)
    TabText.Font = FontStyle
    TabText.TextSize = 12
    TabText.Parent = TabBtn

    local TabLine = Instance.new("Frame")
    TabLine.Name = "TabLine"
    TabLine.Size = UDim2.new(0.4, 0, 0, 1)
    TabLine.Position = UDim2.new(0.3, 0, 1, -1)
    TabLine.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    TabLine.BorderSizePixel = 0
    TabLine.Visible = (i == 1)
    TabLine.Parent = TabBtn

    -- Safe click targeting logic looking explicitly for asset tags
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do 
            p.Visible = false 
        end
        
        for _, t in ipairs(TabContainer:GetChildren()) do
            if t:IsA("TextButton") then
                if t:FindFirstChild("TabIcon") then t.TabIcon.ImageColor3 = Color3.fromRGB(130, 130, 130) end
                if t:FindFirstChild("TabText") then t.TabText.TextColor3 = Color3.fromRGB(130, 130, 130) end
                if t:FindFirstChild("TabLine") then t.TabLine.Visible = false end
            end
        end
        
        Page.Visible = true
        TabIcon.ImageColor3 = Color3.fromRGB(240, 240, 240)
        TabText.TextColor3 = Color3.fromRGB(240, 240, 240)
        TabLine.Visible = true
    end)
end

local NavigationLine = Instance.new("Frame")
NavigationLine.Size = UDim2.new(1, 0, 0, 1)
NavigationLine.Position = UDim2.new(0, 0, 0, 81)
NavigationLine.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NavigationLine.BorderSizePixel = 0
NavigationLine.Parent = MainFrame


-- [[ COMPONENT FACTORY METHODS ]] --

function Library:CreateSection(parentPage, name, column)
    local targetCol = (column == "Right") and Pages[parentPage].RightCol or Pages[parentPage].LeftCol
    
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = name .. "Section"
    SectionFrame.Size = UDim2.new(1, 0, 0, 20)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = targetCol

    local CustomHeader = Instance.new("Frame")
    CustomHeader.Size = UDim2.new(1, 0, 0, 15)
    CustomHeader.BackgroundTransparency = 1
    CustomHeader.Parent = SectionFrame

    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Text = " " .. name .. " "
    SectionLabel.Font = FontStyle
    SectionLabel.TextSize = 11
    SectionLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    SectionLabel.BackgroundTransparency = 0
    SectionLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SectionLabel.Size = UDim2.new(0, math.clamp(#name * 7, 30, 120), 1, 0)
    SectionLabel.ZIndex = 2
    SectionLabel.Parent = CustomHeader

    local InlineLine = Instance.new("Frame")
    InlineLine.Size = UDim2.new(1, 0, 0, 1)
    InlineLine.Position = UDim2.new(0, 0, 0.5, 0)
    InlineLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    InlineLine.BorderSizePixel = 0
    InlineLine.ZIndex = 1
    InlineLine.Parent = CustomHeader

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -15)
    Container.Position = UDim2.new(0, 0, 0, 18)
    Container.BackgroundTransparency = 1
    Container.Parent = SectionFrame

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 8)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Container

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SectionFrame.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 25)
    end)

    return Container
end

function Library:CreateToggle(section, text, default, callback)
    local enabled = default or false
    callback = callback or function() end

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 18)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = section

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 10, 0, 10)
    Checkbox.Position = UDim2.new(0, 4, 0.5, -5)
    Checkbox.BackgroundColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(30, 30, 30)
    Checkbox.BorderColor3 = Color3.fromRGB(60, 60, 60)
    Checkbox.Text = ""
    Checkbox.Parent = ToggleFrame

    local Gradient = Instance.new("UIGradient")
    Gradient.Rotation = 90
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(130,130,130))
    })
    Gradient.Parent = Checkbox

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -25, 1, 0)
    Label.Position = UDim2.new(0, 22, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(110, 110, 110)
    Label.Font = FontStyle
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local function update()
        Checkbox.BackgroundColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(30, 30, 30)
        Label.TextColor3 = enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(110, 110, 110)
        callback(enabled)
    end

    Checkbox.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)
    
    return ToggleFrame
end

function Library:CreateSlider(section, text, min, max, default, unit, callback)
    local value = default or min
    callback = callback or function() end

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 30)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = section

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 14)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.Font = FontStyle
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local ControlGroup = Instance.new("Frame")
    ControlGroup.Size = UDim2.new(0.4, 0, 0, 14)
    ControlGroup.Position = UDim2.new(0.6, 0, 0, 0)
    ControlGroup.BackgroundTransparency = 1
    ControlGroup.Parent = SliderFrame

    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Size = UDim2.new(1, -25, 1, 0)
    ValueDisplay.BackgroundTransparency = 1
    ValueDisplay.Text = tostring(value) .. "/" .. tostring(max) .. unit
    ValueDisplay.TextColor3 = Color3.fromRGB(140, 140, 140)
    ValueDisplay.Font = FontStyle
    ValueDisplay.TextSize = 11
    ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
    ValueDisplay.Parent = ControlGroup

    local MinusBtn = Instance.new("TextButton")
    MinusBtn.Size = UDim2.new(0, 10, 0, 14)
    MinusBtn.Position = UDim2.new(1, -20, 0, 0)
    MinusBtn.BackgroundTransparency = 1
    MinusBtn.Text = "-"
    MinusBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    MinusBtn.Font = FontStyle
    MinusBtn.TextSize = 11
    MinusBtn.Parent = ControlGroup

    local PlusBtn = MinusBtn:Clone()
    PlusBtn.Text = "+"
    PlusBtn.Position = UDim2.new(1, -8, 0, 0)
    PlusBtn.Parent = ControlGroup

    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(1, -10, 0, 8)
    Track.Position = UDim2.new(0, 4, 0, 18)
    Track.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Track.BorderColor3 = Color3.fromRGB(45, 45, 45)
    Track.Text = ""
    Track.AutoButtonColor = false
    Track.Parent = SliderFrame

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    Fill.BorderSizePixel = 0
    Fill.Parent = Track

    local FillGradient = Instance.new("UIGradient")
    FillGradient.Rotation = 90
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120,120,120))
    })
    FillGradient.Parent = Fill

    local function updateSliderPosition(inputPosition)
        local delta = math.clamp((inputPosition.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * delta)
        Fill.Size = UDim2.new(delta, 0, 1, 0)
        ValueDisplay.Text = tostring(value) .. "/" .. tostring(max) .. unit
        callback(value)
    end

    local dragging = false
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSliderPosition(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderPosition(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    MinusBtn.MouseButton1Click:Connect(function()
        value = math.clamp(value - 1, min, max)
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        ValueDisplay.Text = tostring(value) .. "/" .. tostring(max) .. unit
        callback(value)
    end)

    PlusBtn.MouseButton1Click:Connect(function()
        value = math.clamp(value + 1, min, max)
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        ValueDisplay.Text = tostring(value) .. "/" .. tostring(max) .. unit
        callback(value)
    end)

    return SliderFrame
end

function Library:CreateDropdown(section, text, defaultSelected, optionsList, callback)
    local cb = callback or function() end
    local opened = false

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = text .. "DropdownFrame"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 34)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = section

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 14)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.Font = FontStyle
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 16)
    Button.Position = UDim2.new(0, 4, 0, 16)
    Button.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    Button.BorderColor3 = Color3.fromRGB(45, 45, 48)
    Button.Text = defaultSelected or "Select"
    Button.TextColor3 = Color3.fromRGB(180, 180, 185)
    Button.Font = FontStyle
    Button.TextSize = 10
    Button.Parent = DropdownFrame

    local OptionsPanel = Instance.new("Frame")
    OptionsPanel.Size = UDim2.new(1, -8, 0, 0)
    OptionsPanel.Position = UDim2.new(0, 4, 0, 34)
    OptionsPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    OptionsPanel.BorderColor3 = Color3.fromRGB(40, 40, 45)
    OptionsPanel.ClipsDescendants = true
    OptionsPanel.Visible = false
    OptionsPanel.ZIndex = 10
    OptionsPanel.Parent = DropdownFrame

    local Layout = Instance.new("UIListLayout")
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = OptionsPanel

    for _, option in ipairs(optionsList) do
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Size = UDim2.new(1, 0, 0, 16)
        OptionBtn.BackgroundTransparency = 1
        OptionBtn.Text = option
        OptionBtn.TextColor3 = Color3.fromRGB(140, 140, 145)
        OptionBtn.Font = FontStyle
        OptionBtn.TextSize = 10
        OptionBtn.Parent = OptionsPanel

        OptionBtn.MouseButton1Click:Connect(function()
            Button.Text = option
            opened = false
            OptionsPanel.Visible = false
            DropdownFrame.Size = UDim2.new(1, 0, 0, 34)
            OptionsPanel.Size = UDim2.new(1, -8, 0, 0)
            
            if section:FindFirstChildOfClass("UIListLayout") then
                section.Size = UDim2.new(1, 0, 0, section.UIListLayout.AbsoluteContentSize.Y)
            end
            pcall(cb, option)
        end)
    end

    Button.MouseButton1Click:Connect(function()
        opened = not opened
        OptionsPanel.Visible = opened
        
        local totalOptionsHeight = #optionsList * 16
        local targetFrameHeight = opened and (34 + totalOptionsHeight) or 34
        local targetPanelHeight = opened and totalOptionsHeight or 0
        
        DropdownFrame.Size = UDim2.new(1, 0, 0, targetFrameHeight)
        OptionsPanel.Size = UDim2.new(1, -8, 0, targetPanelHeight)
        
        if section:FindFirstChildOfClass("UIListLayout") then
            section.Size = UDim2.new(1, 0, 0, section.UIListLayout.AbsoluteContentSize.Y)
        end
    end)

    return DropdownFrame
end

-- [[ INTEGRATED GRADIENT SPECTRUM COLOR PICKER ]] --
function Library:CreateColorPicker(section, labelText, defaultColor, callback)
    local cb = callback or function() end
    local opened = false

    local PickerContainer = Instance.new("Frame")
    PickerContainer.Name = labelText .. "PickerContainer"
    PickerContainer.Size = UDim2.new(1, 0, 0, 18)
    PickerContainer.BackgroundTransparency = 1
    PickerContainer.Parent = section

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -25, 0, 18)
    Lbl.Position = UDim2.new(0, 4, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = labelText
    Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    Lbl.Font = FontStyle
    Lbl.TextSize = 11
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = PickerContainer

    local ColorDisplay = Instance.new("TextButton")
    ColorDisplay.Size = UDim2.new(0, 16, 0, 10)
    ColorDisplay.Position = UDim2.new(1, -22, 0, 4)
    ColorDisplay.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
    ColorDisplay.BorderColor3 = Color3.fromRGB(65, 65, 65)
    ColorDisplay.Text = ""
    ColorDisplay.Parent = PickerContainer

    local SpectrumFrame = Instance.new("Frame")
    SpectrumFrame.Size = UDim2.new(1, -8, 0, 0)
    SpectrumFrame.Position = UDim2.new(0, 4, 0, 22)
    SpectrumFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpectrumFrame.BorderColor3 = Color3.fromRGB(35, 35, 35)
    SpectrumFrame.ClipsDescendants = true
    SpectrumFrame.Visible = false
    SpectrumFrame.Parent = PickerContainer

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
    })
    Gradient.Parent = SpectrumFrame

    local function UpdateColor(input)
        local totalSize = SpectrumFrame.AbsoluteSize.X
        if totalSize <= 0 then return end
        local relativeX = math.clamp(input.Position.X - SpectrumFrame.AbsolutePosition.X, 0, totalSize)
        local percentage = relativeX / totalSize

        local colorKeys = Gradient.Color.Keypoints
        local leftKey, rightKey = colorKeys[1], colorKeys[#colorKeys]

        for i = 1, #colorKeys - 1 do
            if percentage >= colorKeys[i].Time and percentage <= colorKeys[i+1].Time then
                leftKey = colorKeys[i]
                rightKey = colorKeys[i+1]
                break
            end
        end

        local ratio = (percentage - leftKey.Time) / (rightKey.Time - leftKey.Time)
        local chosenColor = leftKey.Value:Lerp(rightKey.Value, ratio)

        ColorDisplay.BackgroundColor3 = chosenColor
        pcall(cb, chosenColor)
    end

    local activeSelecting = false

    SpectrumFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeSelecting = true
            UpdateColor(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if activeSelecting and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateColor(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeSelecting = false
        end
    end)

    ColorDisplay.MouseButton1Click:Connect(function()
        opened = not opened
        SpectrumFrame.Visible = opened
        
        local targetContainerHeight = opened and 38 or 18
        local targetSpectrumHeight = opened and 12 or 0
        
        TweenService:Create(PickerContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetContainerHeight)}):Play()
        TweenService:Create(SpectrumFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -8, 0, targetSpectrumHeight)}):Play()
        
        task.wait(0.2)
        if section:FindFirstChildOfClass("UIListLayout") then
            section.Size = UDim2.new(1, 0, 0, section.UIListLayout.AbsoluteContentSize.Y)
        end
    end)

    return PickerContainer
end

-- Default fallback active initialization window page visibility state assignment
ContentFrame.CombatPage.Visible = true

return Library
