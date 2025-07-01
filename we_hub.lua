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

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name   = "ESPMenuGui"
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

-- Title bar
local titleBar = Instance.new("Frame", menu)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ESP MENÜSÜ"
title.TextColor3 = Color3.fromRGB(200, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- Close button
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.BorderSizePixel = 0

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

-- ESP category button (now rectangular)
local btnESPcat = Instance.new("TextButton", sidebar)
btnESPcat.Name = "ESPCategory"
btnESPcat.Size = UDim2.new(1, -10, 0, 40)
btnESPcat.Position = UDim2.new(0, 5, 0, 10)
btnESPcat.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
btnESPcat.BorderSizePixel = 0
btnESPcat.Text = "ESP ▼"
btnESPcat.TextColor3 = Color3.fromRGB(220,220,255)
btnESPcat.Font = Enum.Font.GothamBold
btnESPcat.TextSize = 16
btnESPcat.AutoButtonColor = false

-- Button factory for rectangular buttons
local function newButton(text, sizeX, sizeY, pos, parent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = sizeX and UDim2.fromOffset(sizeX, sizeY) or UDim2.new(0, 260, 0, 36)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(220,220,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = text
    btn.AutoButtonColor = false
    
    btn.MouseEnter:Connect(function() 
        btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
        TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = Color3.new(1,1,1)}):Play()
    end)
    
    btn.MouseLeave:Connect(function() 
        btn.BackgroundColor3 = Color3.fromRGB(40,40,50) 
        TweenService:Create(btn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(220,220,255)}):Play()
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

-- ESP toggles - now with rectangular buttons
local btnToggleESP = newButton("ESP: Kapalı", nil, nil, UDim2.new(0,0,0,40), espPanel)
local btnToggleName = newButton("İsimler: Açık", nil, nil, UDim2.new(0,0,0,90), espPanel)
local btnToggleBox = newButton("Box: Açık", nil, nil, UDim2.new(0,0,0,140), espPanel)
local btnToggleDH = newButton("Can+Uzaklık: Açık", nil, nil, UDim2.new(0,0,0,190), espPanel)

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

-- ESP toggle callbacks
btnToggleESP.MouseButton1Click:Connect(function()
    ESP_Enabled = not ESP_Enabled
    btnToggleESP.Text = "ESP: " .. (ESP_Enabled and "Açık" or "Kapalı")
    btnToggleESP.BackgroundColor3 = ESP_Enabled and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(40,40,50)
end)

btnToggleName.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    btnToggleName.Text = "İsimler: " .. (ShowNames and "Açık" or "Kapalı")
    btnToggleName.BackgroundColor3 = ShowNames and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(40,40,50)
end)

btnToggleBox.MouseButton1Click:Connect(function()
    ShowBoxes = not ShowBoxes
    btnToggleBox.Text = "Box: " .. (ShowBoxes and "Açık" or "Kapalı")
    btnToggleBox.BackgroundColor3 = ShowBoxes and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(40,40,50)
end)

btnToggleDH.MouseButton1Click:Connect(function()
    ShowDistanceHealth = not ShowDistanceHealth
    btnToggleDH.Text = "Can+Uzaklık: " .. (ShowDistanceHealth and "Açık" or "Kapalı")
    btnToggleDH.BackgroundColor3 = ShowDistanceHealth and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(40,40,50)
end)

-- Set initial button states
btnToggleName.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
btnToggleBox.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
btnToggleDH.BackgroundColor3 = Color3.fromRGB(50, 80, 50)

-- Draggable menu
local dragging
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = menu.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInput.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        menu.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
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

-- ESP rendering loop (unchanged)
RunService.RenderStepped:Connect(function()
    if not ESP_Enabled then
        -- Cleanup
        for pl, part in pairs(boxParts) do
            if part then part:Destroy() end
            boxParts[pl] = nil
        end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then
                local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if hrp:FindFirstChild("ESP_Name") then hrp.ESP_Name:Destroy() end
                    if hrp:FindFirstChild("ESP_DH") then hrp.ESP_DH:Destroy() end
                end
            end
        end
        return
    end

    local lpChar = localPlayer.Character
    if not lpChar or not lpChar:FindFirstChild("HumanoidRootPart") then return end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= localPlayer and pl.Character then
            local char = pl.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- BOX
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
                        adorn.Color3       = Color3.new(1,0,0)
                        boxParts[pl] = part
                    end
                    part.Size   = size
                    part.CFrame = cf
                    part:FindFirstChild("ESP_Box").Size = size
                end
            else
                if boxParts[pl] then
                    boxParts[pl]:Destroy()
                    boxParts[pl] = nil
                end
            end

            -- NAME
            if ShowNames then
                if not hrp:FindFirstChild("ESP_Name") then
                    local gui = Instance.new("BillboardGui", hrp)
                    gui.Name        = "ESP_Name"
                    gui.Adornee     = hrp
                    gui.Size        = UDim2.new(0,100,0,25)
                    gui.StudsOffset = Vector3.new(0,3,0)
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
                if hrp:FindFirstChild("ESP_Name") then hrp.ESP_Name:Destroy() end
            end

            -- DIST+HEALTH
            if ShowDistanceHealth then
                if not hrp:FindFirstChild("ESP_DH") then
                    local gui = Instance.new("BillboardGui", hrp)
                    gui.Name        = "ESP_DH"
                    gui.Adornee     = hrp
                    gui.Size        = UDim2.new(0,100,0,30)
                    gui.StudsOffset = Vector3.new(0,1,0)
                    gui.AlwaysOnTop = true
                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size              = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font              = Enum.Font.Gotham
                    lbl.TextSize          = 14
                    lbl.TextColor3        = Color3.new(1,1,0)
                end
                local gui = hrp:FindFirstChild("ESP_DH")
                local lbl = gui:FindFirstChildOfClass("TextLabel")
                local dist = (hrp.Position - lpChar.HumanoidRootPart.Position).Magnitude
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local hp   = hum and math.floor(hum.Health) or 0
                lbl.Text = string.format("U: %d  H: %d", math.floor(dist), hp)
            else
                if hrp:FindFirstChild("ESP_DH") then hrp.ESP_DH:Destroy() end
            end
        end
    end
end)
