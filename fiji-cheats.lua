-- LocalScript in StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local configFileName = "fiji_cheats_config.json"

--=== KEYBINDS ===--
local keybinds = {
    ESP = Enum.KeyCode.V,
    Fly = Enum.KeyCode.F,
    Noclip = Enum.KeyCode.N,
    NoFall = Enum.KeyCode.X,
    Spin = Enum.KeyCode.T,
}

local currentRemapping = nil

--=== GUI THEME COLORS ===--
local COLORS = {
    MainBg = Color3.fromRGB(26, 27, 35),
    CardBg = Color3.fromRGB(35, 36, 47),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextSub = Color3.fromRGB(130, 133, 148),
    ToggleOn = Color3.fromRGB(108, 130, 230),
    ToggleOff = Color3.fromRGB(56, 57, 70),
    KeybindBg = Color3.fromRGB(44, 45, 58),
    KeybindBorder = Color3.fromRGB(60, 61, 78)
}

--=== MAIN INTERFACE ===--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FijiCheatsGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = true 
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 360, 0, 560)
mainFrame.Position = UDim2.new(0.5, -180, 0.5, -280)
mainFrame.BackgroundColor3 = COLORS.MainBg
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Top Header Padding/Container
local headerContainer = Instance.new("Frame")
headerContainer.Size = UDim2.new(1, 0, 0, 65)
headerContainer.BackgroundTransparency = 1
headerContainer.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 1, 0)
title.Position = UDim2.new(0, 24, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Fiji Cheats"
title.TextColor3 = COLORS.TextMain
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = headerContainer

-- Line divider under header
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 1, 0)
divider.BackgroundColor3 = Color3.fromRGB(38, 39, 51)
divider.BorderSizePixel = 0
divider.Parent = headerContainer

-- Scroll Container for content
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, 0, 1, -66)
contentContainer.Position = UDim2.new(0, 0, 0, 66)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 4
contentContainer.ScrollBarImageColor3 = COLORS.ToggleOff
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 600) -- Expanded canvas for config menu extension
contentContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = contentContainer

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 14)
padding.Parent = contentContainer

--=== FACTORY FUNCTION FOR ITEMS ===--
local function createModuleCard(name, description, defaultKeyStr, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 0, 75)
    card.BackgroundColor3 = COLORS.CardBg
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = contentContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    -- Text wrapper
    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(0.55, 0, 1, 0)
    textContainer.Position = UDim2.new(0, 16, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = card

    local mainLabel = Instance.new("TextLabel")
    mainLabel.Size = UDim2.new(1, 0, 0, 40)
    mainLabel.BackgroundTransparency = 1
    mainLabel.Text = name
    mainLabel.TextColor3 = COLORS.TextMain
    mainLabel.Font = Enum.Font.GothamBold
    mainLabel.TextSize = 18
    mainLabel.TextXAlignment = Enum.TextXAlignment.Left
    mainLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    mainLabel.Parent = textContainer

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 30)
    subLabel.Position = UDim2.new(0, 0, 0, 36)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = description
    subLabel.TextColor3 = COLORS.TextSub
    subLabel.Font = Enum.Font.SourceSans
    subLabel.TextSize = 14
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.TextYAlignment = Enum.TextYAlignment.Top
    subLabel.Parent = textContainer

    -- Keybind Remap Button (Right side square)
    local remap = Instance.new("TextButton")
    remap.Size = UDim2.new(0, 32, 0, 32)
    remap.Position = UDim2.new(1, -44, 0.5, -16)
    remap.BackgroundColor3 = COLORS.KeybindBg
    remap.TextColor3 = COLORS.TextSub
    remap.Font = Enum.Font.Code
    remap.TextSize = 14
    remap.Text = defaultKeyStr
    remap.Parent = card
    
    local remapCorner = Instance.new("UICorner", remap)
    remapCorner.CornerRadius = UDim.new(0, 6)
    local remapStroke = Instance.new("UIStroke", remap)
    remapStroke.Color = COLORS.KeybindBorder
    remapStroke.Thickness = 1

    -- Toggle Switch Background
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 52, 0, 28)
    switch.Position = UDim2.new(1, -112, 0.5, -14)
    switch.BackgroundColor3 = COLORS.ToggleOff
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = card
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

    -- Toggle Knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 3, 0.5, -11)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = switch
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    return {switch = switch, knob = knob, remap = remap}
end

-- Generate UI Components
local modulesUI = {
    ESP = createModuleCard("Player ESP", "See players through walls", "V", 1),
    Fly = createModuleCard("Flight", "Fly seamlessly based on camera direction", "F", 2),
    Noclip = createModuleCard("Noclip", "Pass completely through solid objects", "N", 3),
    NoFall = createModuleCard("No Fall Damage", "Smart raycast checks 2s before landing", "X", 4),
    Spin = createModuleCard("Anti-Aim Spin", "Spin character around at high speed", "T", 5)
}

-- WalkSpeed Slider Element
local sliderCard = Instance.new("Frame")
sliderCard.Size = UDim2.new(1, -32, 0, 65)
sliderCard.BackgroundColor3 = COLORS.CardBg
sliderCard.BorderSizePixel = 0
sliderCard.LayoutOrder = 6
sliderCard.Parent = contentContainer
Instance.new("UICorner", sliderCard).CornerRadius = UDim.new(0, 8)

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -32, 0, 30)
speedTitle.Position = UDim2.new(0, 16, 0, 6)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "WalkSpeed: 16"
speedTitle.TextColor3 = COLORS.TextMain
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 15
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = sliderCard

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -32, 0, 6)
sliderTrack.Position = UDim2.new(0, 16, 0, 44)
sliderTrack.BackgroundColor3 = COLORS.ToggleOff
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = sliderCard
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0, 0, 0.5, -8)
sliderKnob.BackgroundColor3 = COLORS.ToggleOn
sliderKnob.Text = ""
sliderKnob.Parent = sliderTrack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

-- Config Save/Load Panel Element
local configCard = Instance.new("Frame")
configCard.Size = UDim2.new(1, -32, 0, 65)
configCard.BackgroundColor3 = COLORS.CardBg
configCard.BorderSizePixel = 0
configCard.LayoutOrder = 7
configCard.Parent = contentContainer
Instance.new("UICorner", configCard).CornerRadius = UDim.new(0, 8)

local configTitle = Instance.new("TextLabel")
configTitle.Size = UDim2.new(0.4, 0, 1, 0)
configTitle.Position = UDim2.new(0, 16, 0, 0)
configTitle.BackgroundTransparency = 1
configTitle.Text = "Menu Configs"
configTitle.TextColor3 = COLORS.TextMain
configTitle.Font = Enum.Font.GothamBold
configTitle.TextSize = 16
configTitle.TextXAlignment = Enum.TextXAlignment.Left
configTitle.Parent = configCard

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 75, 0, 32)
saveBtn.Position = UDim2.new(1, -175, 0.5, -16)
saveBtn.BackgroundColor3 = COLORS.ToggleOn
saveBtn.TextColor3 = COLORS.TextMain
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 13
saveBtn.Text = "Save"
saveBtn.Parent = configCard
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(0, 75, 0, 32)
loadBtn.Position = UDim2.new(1, -91, 0.5, -16)
loadBtn.BackgroundColor3 = COLORS.KeybindBg
loadBtn.TextColor3 = COLORS.TextMain
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 13
loadBtn.Text = "Load"
loadBtn.Parent = configCard
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
local loadStroke = Instance.new("UIStroke", loadBtn)
loadStroke.Color = COLORS.KeybindBorder
loadStroke.Thickness = 1

--=== FUNCTIONAL STATES ===--
local states = { ESP = false, Fly = false, Noclip = false, NoFall = false, Spin = false }
local flightConnection, spinConnection, noclipConnection, noFallConnection = nil, nil, nil, nil
local isDragging = false
local flightSpeed = 60
local targetWalkSpeed = 16

local function updateToggleVisual(ui, enabled)
    ui.switch.BackgroundColor3 = enabled and COLORS.ToggleOn or COLORS.ToggleOff
    ui.knob.Position = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
end

local function updateRemapVisual(ui, key)
    ui.remap.Text = key and key.Name or "?"
end

-- 1. Persistent WalkSpeed Core Engine Loop
RunService.PreSimulation:Connect(function()
    local char = localPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= targetWalkSpeed then
        hum.WalkSpeed = targetWalkSpeed
    end
end)

-- 2. ESP
local function refreshEsp()
    for _, plr in Players:GetPlayers() do
        if plr ~= localPlayer and plr.Character then
            if states.ESP then
                if not plr.Character:FindFirstChild("ESP_Highlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "ESP_Highlight"
                    h.FillColor = Color3.fromRGB(108, 130, 230)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.4
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = plr.Character
                end
            else
                local h = plr.Character:FindFirstChild("ESP_Highlight")
                if h then h:Destroy() end
            end
        end
    end
end

local function toggleEsp()
    states.ESP = not states.ESP
    updateToggleVisual(modulesUI.ESP, states.ESP)
    refreshEsp()
end

-- 3. Isolated Flight
local function toggleFly()
    states.Fly = not states.Fly
    updateToggleVisual(modulesUI.Fly, states.Fly)
    
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if states.Fly then
        if not hrp then return end
        
        flightConnection = RunService.RenderStepped:Connect(function(dt)
            if not states.Fly or not hrp then return end
            
            local velocity = Vector3.zero
            local cf = camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity += cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity -= cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity -= cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity += cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity -= Vector3.new(0, 1, 0) end
            
            hrp.AssemblyLinearVelocity = Vector3.zero
            if velocity.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (velocity.Unit * flightSpeed * dt)
            end
        end)
    else
        if flightConnection then flightConnection:Disconnect() flightConnection = nil end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
end

-- 4. Isolated Noclip
local function toggleNoclip()
    states.Noclip = not states.Noclip
    updateToggleVisual(modulesUI.Noclip, states.Noclip)
    
    if states.Noclip then
        if not noclipConnection then
            noclipConnection = RunService.Stepped:Connect(function()
                if states.Noclip and localPlayer.Character then
                    for _, part in pairs(localPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
        if localPlayer.Character then
            for _, part in pairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- 5. Predictive No Fall Damage (2s Raycast Rule)
local function toggleNoFall()
    states.NoFall = not states.NoFall
    updateToggleVisual(modulesUI.NoFall, states.NoFall)
    
    if states.NoFall then
        noFallConnection = RunService.PreSimulation:Connect(function()
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and states.NoFall and hrp.AssemblyLinearVelocity.Y < -35 then
                local fallSpeed = math.abs(hrp.AssemblyLinearVelocity.Y)
                local maxCheckDistance = fallSpeed * 2.0
                
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                
                local result = workspace:Raycast(hrp.Position, Vector3.new(0, -maxCheckDistance, 0), params)
                
                if result then
                    local currentVel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(currentVel.X, 0, currentVel.Z)
                    
                    if hum:GetState() == Enum.HumanoidStateType.Freefall then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    else
        if noFallConnection then noFallConnection:Disconnect() noFallConnection = nil end
    end
end

-- 6. Anti-Aim Spin
local function toggleSpin()
    states.Spin = not states.Spin
    updateToggleVisual(modulesUI.Spin, states.Spin)
    if states.Spin then
        spinConnection = RunService.RenderStepped:Connect(function(dt)
            local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame *= CFrame.Angles(0, 150 * dt, 0) end
        end)
    else
        if spinConnection then spinConnection:Disconnect() end
    end
end

--=== CONFIGURATION IO LOGIC ===--
local function saveConfig()
    if not writefile then return print("Your exploit execution software lacks writefile support.") end
    
    local bindStorage = {}
    for feature, key in pairs(keybinds) do
        bindStorage[feature] = key and key.Name or "nil"
    end
    
    local payload = {
        states = states,
        targetWalkSpeed = targetWalkSpeed,
        keybinds = bindStorage
    }
    
    local success, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
    if success then
        writefile(configFileName, encoded)
    end
end

local function loadConfig()
    if not readfile or not isfile or not isfile(configFileName) then return print("No saved config file located.") end
    
    local readSuccess, content = pcall(function() return readfile(configFileName) end)
    if not readSuccess then return end
    
    local decodeSuccess, payload = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodeSuccess or not payload then return end
    
    -- Sync WalkSpeed
    if payload.targetWalkSpeed then
        targetWalkSpeed = payload.targetWalkSpeed
        speedTitle.Text = "WalkSpeed: " .. targetWalkSpeed
        local pct = math.clamp((targetWalkSpeed - 16) / 184, 0, 1)
        sliderKnob.Position = UDim2.new(pct, -8, 0.5, -8)
    end
    
    -- Sync Binds
    if payload.keybinds then
        for feature, keyName in pairs(payload.keybinds) do
            if keyName == "nil" then
                keybinds[feature] = nil
            else
                pcall(function() keybinds[feature] = Enum.KeyCode[keyName] end)
            end
            updateRemapVisual(modulesUI[feature], keybinds[feature])
        end
    end
    
    -- Sync System Feature States
    if payload.states then
        for feature, enabled in pairs(payload.states) do
            if states[feature] ~= enabled then
                if feature == "ESP" then toggleEsp()
                elseif feature == "Fly" then toggleFly()
                elseif feature == "Noclip" then toggleNoclip()
                elseif feature == "NoFall" then toggleNoFall()
                elseif feature == "Spin" then toggleSpin()
                end
            end
        end
    end
end

-- Bind Button Connections
modulesUI.ESP.switch.MouseButton1Click:Connect(toggleEsp)
modulesUI.Fly.switch.MouseButton1Click:Connect(toggleFly)
modulesUI.Noclip.switch.MouseButton1Click:Connect(toggleNoclip)
modulesUI.NoFall.switch.MouseButton1Click:Connect(toggleNoFall)
modulesUI.Spin.switch.MouseButton1Click:Connect(toggleSpin)

saveBtn.MouseButton1Click:Connect(saveConfig)
loadBtn.MouseButton1Click:Connect(loadConfig)

-- Interactive Keybind Registration Setup
local function startRemapping(feature)
    currentRemapping = feature
    modulesUI[feature].remap.Text = "..."
end

for key, uiTable in pairs(modulesUI) do
    uiTable.remap.MouseButton1Click:Connect(function()
        startRemapping(key)
    end)
end

-- Key Input Systems Execution
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if currentRemapping then
        if input.KeyCode == Enum.KeyCode.Escape then
            keybinds[currentRemapping] = nil
        else
            keybinds[currentRemapping] = input.KeyCode
        end
        updateRemapVisual(modulesUI[currentRemapping], keybinds[currentRemapping])
        currentRemapping = nil
        return
    end
    
    if input.KeyCode == Enum.KeyCode.Home then
        mainFrame.Visible = not mainFrame.Visible
    elseif input.KeyCode == keybinds.ESP then toggleEsp()
    elseif input.KeyCode == keybinds.Fly then toggleFly()
    elseif input.KeyCode == keybinds.Noclip then toggleNoclip()
    elseif input.KeyCode == keybinds.NoFall then toggleNoFall()
    elseif input.KeyCode == keybinds.Spin then toggleSpin()
    end
end)

-- Responsive Slider Controller Logic
sliderKnob.MouseButton1Down:Connect(function() isDragging = true end)

UserInputService.InputChanged:Connect(function(input)
    if not isDragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local pct = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
    sliderKnob.Position = UDim2.new(pct, -8, 0.5, -8)
    
    targetWalkSpeed = math.round(16 + pct * 184)
    speedTitle.Text = "WalkSpeed: " .. targetWalkSpeed
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
end)

Players.PlayerAdded:Connect(function() task.wait(1) refreshEsp() end)
print("Fiji Cheats Suite Loaded - Press HOME to minimize window")