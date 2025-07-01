-- Services
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UserInput    = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer

-- State
local menuVisible        = true
local espOpen            = false
local ESP_Enabled        = false
local ShowNames          = true
local ShowBoxes          = true
local ShowDistanceHealth = true

-- BoxParts storage
local boxParts = {}

-- Helper: compute character bounds
local function computeBounds(character)
    local minV, maxV
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local p0 = part.Position - part.Size/2
            local p1 = part.Position + part.Size/2
            if not minV then
                minV, maxV = p0, p1
            else
                minV = Vector3.new(math.min(minV.X,p0.X), math.min(minV.Y,p0.Y), math.min(minV.Z,p0.Z))
                maxV = Vector3.new(math.max(maxV.X,p1.X), math.max(maxV.Y,p1.Y), math.max(maxV.Z,p1.Z))
            end
        end
    end
    return minV, maxV
end

-- Helper: health-based color interpolation
local function getHealthColor(healthPercent)
    -- Green (0,1,0) to Red (1,0,0) based on health
    return Color3.new(1 - healthPercent, healthPercent, 0)
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPMenuGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Main menu frame
local menu = Instance.new("Frame")
menu.Name               = "Menu"
menu.Size               = UDim2.new(0, 500, 0, 350)
menu.Position           = UDim2.new(0.5, 0, 0.5, 0)
menu.AnchorPoint        = Vector2.new(0.5, 0.5)
menu.BackgroundColor3   = Color3.fromRGB(20, 20, 25)
menu.BackgroundTransparency = 0.3
menu.BorderSizePixel    = 0
menu.Visible            = menuVisible
menu.Parent             = screenGui

-- Mobil için ekranın sağ üstüne buton (Aç/Kapat)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 30)
toggleBtn.Position = UDim2.new(1, -70, 0, 10)
toggleBtn.AnchorPoint = Vector2.new(0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "Menü"
toggleBtn.TextSize = 14
toggleBtn.Parent = screenGui

toggleBtn.MouseButton1Click:Connect(function()
	menuVisible = not menuVisible
	menu.Visible = menuVisible
end)


-- Title bar with gradient
local titleBar = Instance.new("Frame", menu)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2

-- Gradient effect
local gradient = Instance.new("UIGradient", titleBar)
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
})

-- "WE HUB" Title with Shadow
local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "WE HUB"
title.TextColor3 = Color3.fromRGB(200, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 5

local shadow = Instance.new("TextLabel", titleBar)
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.Position = UDim2.new(0, 1, 0, 1)
shadow.BackgroundTransparency = 1
shadow.Text = "WE HUB"
shadow.TextColor3 = Color3.new(0, 0, 0)
shadow.Font = Enum.Font.GothamBold
shadow.TextSize = 22
shadow.TextTransparency = 0.5
shadow.ZIndex = 4
shadow.TextXAlignment = Enum.TextXAlignment.Center
shadow.TextYAlignment = Enum.TextYAlignment.Center

-- Close button with style
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.ZIndex = 10
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false

-- Close button hover effects
closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end)
closeBtn.MouseButton1Click:Connect(function()
    menuVisible = false
    menu.Visible = false
end)

-- Left sidebar
local sidebar = Instance.new("Frame", menu)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 120, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
sidebar.BackgroundTransparency = 0.2

-- ESP category button with color feedback
local btnESPcat = Instance.new("TextButton", sidebar)
btnESPcat.Name = "ESPCategory"
btnESPcat.Size = UDim2.new(1, -10, 0, 40)
btnESPcat.Position = UDim2.new(0, 5, 0, 10)
btnESPcat.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
btnESPcat.BorderSizePixel = 0
btnESPcat.Text = "ESP ▼"
btnESPcat.TextColor3 = Color3.fromRGB(220,220,255)
btnESPcat.Font = Enum.Font.GothamBold
btnESPcat.TextSize = 16
btnESPcat.AutoButtonColor = false

-- Button factory for rectangular buttons with color feedback
local function newButton(text, sizeX, sizeY, pos, parent, initialState)
    local btn = Instance.new("TextButton", parent)
    btn.Size = sizeX and UDim2.fromOffset(sizeX, sizeY) or UDim2.new(0, 260, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = initialState and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(220,220,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = false
    
    btn.MouseEnter:Connect(function() 
        local currentState = btn.Text:find("Açık") ~= nil
        btn.BackgroundColor3 = currentState and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(200, 80, 80)
    end)
    
    btn.MouseLeave:Connect(function() 
        local currentState = btn.Text:find("Açık") ~= nil
        btn.BackgroundColor3 = currentState and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    end)
    
    return btn
end

-- ESP options panel
local espPanel = Instance.new("Frame", menu)
espPanel.Name = "ESPPanel"
espPanel.Size = UDim2.new(1, -140, 0, 220)
espPanel.Position = UDim2.new(0, 130, 0, 100)
espPanel.BackgroundTransparency = 1
espPanel.Visible = false

-- Panel title
local espTitle = Instance.new("TextLabel", espPanel)
espTitle.Size = UDim2.new(1, 0, 0, 30)
espTitle.Position = UDim2.new(0, 0, 0, 0)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP AYARLARI"
espTitle.TextColor3 = Color3.fromRGB(180, 180, 255)
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 18
espTitle.TextXAlignment = Enum.TextXAlignment.Left

-- ESP toggles with color feedback
local btnToggleESP = newButton("ESP: Kapalı", nil, nil, UDim2.new(0,0,0,40), espPanel, false)
local btnToggleName = newButton("İsimler: Açık", nil, nil, UDim2.new(0,0,0,90), espPanel, true)
local btnToggleBox = newButton("Box: Açık", nil, nil, UDim2.new(0,0,0,140), espPanel, true)
local btnToggleDH = newButton("Can+Uzaklık: Açık", nil, nil, UDim2.new(0,0,0,190), espPanel, true)

-- Animate espPanel open/close
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
btnESPcat.MouseButton1Click:Connect(function()
    espOpen = not espOpen
    btnESPcat.Text = espOpen and "ESP ▲" or "ESP ▼"
    espPanel.Visible = true
    TweenService:Create(espPanel, tweenInfo, {
        Size = espOpen and UDim2.new(1, -140, 0, 220) or UDim2.new(1, -140, 0, 0)
    }):Play()
    
    if not espOpen then
        task.delay(0.3, function() espPanel.Visible = false end)
    end
end)

-- ESP toggle callbacks with color feedback
btnToggleESP.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    btnToggleESP.Text = "ESP: " .. (ESP_Enabled and "Açık" or "Kapalı")
    btnToggleESP.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    -- Update ESP category button color
    btnESPcat.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
end)

btnToggleName.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    btnToggleName.Text = "İsimler: " .. (ShowNames and "Açık" or "Kapalı")
    btnToggleName.BackgroundColor3 = ShowNames and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
end)

btnToggleBox.MouseButton1Click:Connect(function()
    ShowBoxes = not ShowBoxes
    btnToggleBox.Text = "Box: " .. (ShowBoxes and "Açık" or "Kapalı")
    btnToggleBox.BackgroundColor3 = ShowBoxes and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
end)

btnToggleDH.MouseButton1Click:Connect(function()
    ShowDistanceHealth = not ShowDistanceHealth
    btnToggleDH.Text = "Can+Uzaklık: " .. (ShowDistanceHealth and "Açık" or "Kapalı")
    btnToggleDH.BackgroundColor3 = ShowDistanceHealth and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
end)

-- Draggable menu
local dragging
local dragStart
local startPos

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

local dragging = false
local dragStart, startPos

-- Dokunma ve fare desteği ile taşıma
local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = menu.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        menu.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

-- Tüm input türlerini dinle
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- K tuşu ile aç/kapa menü
UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then
        menuVisible = not menuVisible
        menu.Visible = menuVisible
    end
end)

-- ESP rendering loop with health-based coloring
RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then
        -- Cleanup
        for pl, part in pairs(boxParts) do
            if part then part:Destroy() end
            boxParts[pl] = nil
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then
                local head = pl.Character:FindFirstChild("Head")
                if head then
                    if head:FindFirstChild("ESP_Name") then head.ESP_Name:Destroy() end
                    if head:FindFirstChild("ESP_DH") then head.ESP_DH:Destroy() end
                end
            end
        end
        return
    end

    local lpChar = localPlayer.Character
    if not lpChar then return end

    local lpHead = lpChar:FindFirstChild("Head")
    if not lpHead then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer and pl.Character then
            local char = pl.Character
            local head = char:FindFirstChild("Head")
            if not head then continue end

            -- Calculate distance
            local distance = (head.Position - lpHead.Position).Magnitude

            -- BOX with health-based coloring
            if ShowBoxes then
                local part = boxParts[pl]
                local minV, maxV = computeBounds(char)
                if minV and maxV then
                    local size = maxV - minV + Vector3.new(0.2,0.2,0.2)
                    local cf   = CFrame.new((minV+maxV)/2)
                    
                    if not part or not part.Parent then
                        part = Instance.new("Part")
                        part.Name         = "ESP_BoxPart"
                        part.Anchored     = true
                        part.CanCollide   = false
                        part.Transparency = 1
                        part.Parent       = workspace
                        local adorn = Instance.new("BoxHandleAdornment", part)
                        adorn.Name         = "ESP_Box"
                        adorn.Adornee      = part
                        adorn.AlwaysOnTop  = true
                        adorn.ZIndex       = 5
                        adorn.Transparency = 0.5
                        boxParts[pl] = part
                    end
                    
                    -- Update box size and position
                    part.Size   = size
                    part.CFrame = cf
                    
                    -- Update box color based on health
                    local adorn = part:FindFirstChild("ESP_Box")
                    if adorn then
                        adorn.Size = size
                        
                        -- Get health percentage
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            adorn.Color3 = getHealthColor(healthPercent)
                        else
                            adorn.Color3 = Color3.new(1, 0, 0) -- Red if no humanoid
                        end
                    end
                end
            else
                if boxParts[pl] then
                    boxParts[pl]:Destroy()
                    boxParts[pl] = nil
                end
            end

            -- NAME
            if ShowNames then
                if not head:FindFirstChild("ESP_Name") then
                    local gui = Instance.new("BillboardGui", head)
                    gui.Name        = "ESP_Name"
                    gui.Adornee     = head
                    gui.Size        = UDim2.new(0,100,0,25)
                    gui.StudsOffset = Vector3.new(0,2,0)
                    gui.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size              = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text              = pl.Name
                    lbl.TextColor3        = Color3.new(1,1,1)
                    lbl.Font              = Enum.Font.GothamBold
                    lbl.TextSize          = 16
                end
            else
                if head:FindFirstChild("ESP_Name") then head.ESP_Name:Destroy() end
            end

            -- DIST+HEALTH
            if ShowDistanceHealth then
                if not head:FindFirstChild("ESP_DH") then
                    local gui = Instance.new("BillboardGui", head)
                    gui.Name        = "ESP_DH"
                    gui.Adornee     = head
                    gui.Size        = UDim2.new(0,100,0,30)
                    gui.StudsOffset = Vector3.new(0,0,0)
                    gui.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size              = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font              = Enum.Font.Gotham
                    lbl.TextSize          = 14
                    lbl.TextColor3        = Color3.new(1,1,0)
                end
                local gui = head:FindFirstChild("ESP_DH")
                local lbl = gui:FindFirstChildOfClass("TextLabel")
                local dist = distance
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local hp   = hum and math.floor(hum.Health) or 0
                lbl.Text = string.format("U: %d  H: %d", math.floor(dist), hp)
            else
                if head:FindFirstChild("ESP_DH") then head.ESP_DH:Destroy() end
            end
        end
    end
end)
