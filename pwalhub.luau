--================ FULL MODERN PWAL'S HUB WITH FLY INDICATOR ===================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

--================ GUI ===================
local gui = Instance.new("ScreenGui")
gui.Name = "PWALS_HUB"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,450,0,500)
frame.Position = UDim2.new(0,20,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0,15)

-- Gradient header
local headerGradient = Instance.new("UIGradient", frame)
headerGradient.Rotation = 90
headerGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(60,60,100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(40,40,60))})

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.Text = "PWAL'S HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

--================ TAB BUTTONS ===================
local tabFrame = Instance.new("Frame", frame)
tabFrame.Size = UDim2.new(1,0,0,40)
tabFrame.Position = UDim2.new(0,0,0,50)
tabFrame.BackgroundTransparency = 1

local function createTabButton(text, position)
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1/3,0,1,0)
    btn.Position = position
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,10)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,100,110)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(60,60,70)}):Play() end)
    return btn
end

local customTPBtn = createTabButton("Custom TP", UDim2.new(0,0,0,0))
local tpBtnTab = createTabButton("TP", UDim2.new(1/3,0,0,0))
local otherTabBtn = createTabButton("Other", UDim2.new(2/3,0,0,0))

--================ TAB FRAMES ===================
local function createTabFrame()
    local f = Instance.new("Frame", frame)
    f.Size = UDim2.new(1,-20,1,-110)
    f.Position = UDim2.new(0,10,0,95)
    f.BackgroundColor3 = Color3.fromRGB(35,35,40)
    local corner = Instance.new("UICorner", f)
    corner.CornerRadius = UDim.new(0,12)
    return f
end

local customTPFrame = createTabFrame()
local tpFrame = createTabFrame()
local otherFrame = createTabFrame()

-- Scrollable lists
local function createScroll(frame, yOffset)
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1,-10,1,-(yOffset+10))
    scroll.Position = UDim2.new(0,5,0,yOffset)
    scroll.BackgroundTransparency = 1
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)
    return scroll
end

local newListFrame = createScroll(customTPFrame,60)
local listFrame = createScroll(tpFrame,0)

--================ DATA ===================
local userWaypoints = {}
local waypoints = {
    Selling = {{Name="Sellpoint",Pos=Vector3.new(937,29,-695),Permanent=true}},
    Mining = {
        {Name="Cobalt",Pos=Vector3.new(279,-120,3394),Permanent=true},
        {Name="Emeralds",Pos=Vector3.new(-7809,173,-3338),Permanent=true},
        {Name="Abbysalite",Pos=Vector3.new(-7136,-712,-2544),Permanent=true},
    }
}

local flying = false
local flySpeed = 50
local bv

--================ FUNCTIONS ===================
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function smoothTP(pos)
    local root = getRoot()
    local dist = (root.Position - pos).Magnitude
    local t = math.clamp(dist/70, 0.15, 2)
    TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0,3,0))}):Play()
end

local function slideTab(tabFrame, targetX)
    TweenService:Create(tabFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(targetX,10,0,95)}):Play()
end

customTPBtn.MouseButton1Click:Connect(function()
    slideTab(customTPFrame,0)
    slideTab(tpFrame,1)
    slideTab(otherFrame,2)
end)
tpBtnTab.MouseButton1Click:Connect(function()
    slideTab(customTPFrame,-1)
    slideTab(tpFrame,0)
    slideTab(otherFrame,1)
end)
otherTabBtn.MouseButton1Click:Connect(function()
    slideTab(customTPFrame,-2)
    slideTab(tpFrame,-1)
    slideTab(otherFrame,0)
end)

--================ CUSTOM TP TAB ===================
local saveBtn = Instance.new("TextButton", customTPFrame)
saveBtn.Size = UDim2.new(0.45,-5,0,45)
saveBtn.Position = UDim2.new(0,5,0,5)
saveBtn.Text = "Save Position"
saveBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextScaled = true
local corner = Instance.new("UICorner", saveBtn)
corner.CornerRadius = UDim.new(0,8)

local tpBtnCustom = Instance.new("TextButton", customTPFrame)
tpBtnCustom.Size = UDim2.new(0.45,-5,0,45)
tpBtnCustom.Position = UDim2.new(0.5,0,0,5)
tpBtnCustom.Text = "Teleport Last"
tpBtnCustom.BackgroundColor3 = Color3.fromRGB(60,60,70)
tpBtnCustom.TextColor3 = Color3.new(1,1,1)
tpBtnCustom.Font = Enum.Font.GothamBold
tpBtnCustom.TextScaled = true
local corner2 = Instance.new("UICorner", tpBtnCustom)
corner2.CornerRadius = UDim.new(0,8)

local function rebuildUserList()
    for _,c in pairs(newListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i,wp in ipairs(userWaypoints) do
        local b = Instance.new("TextButton", newListFrame)
        b.Size = UDim2.new(1,0,0,40)
        b.BackgroundColor3 = Color3.fromRGB(50,50,60)
        b.TextColor3 = Color3.fromRGB(0,255,255)
        b.Text = wp.Name .. " ("..math.floor(wp.Pos.X)..","..math.floor(wp.Pos.Y)..","..math.floor(wp.Pos.Z)..")"
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        local corner = Instance.new("UICorner", b)
        corner.CornerRadius = UDim.new(0,8)
        b.MouseButton1Click:Connect(function() smoothTP(wp.Pos) end)
        b.MouseButton2Click:Connect(function() table.remove(userWaypoints,i) rebuildUserList() end)
    end
end

saveBtn.MouseButton1Click:Connect(function()
    local pos = getRoot().Position
    table.insert(userWaypoints,{Name="WP "..#userWaypoints+1, Pos=pos})
    rebuildUserList()
    saveBtn.Text = "Saved!"
    task.wait(0.8)
    saveBtn.Text = "Save Position"
end)

tpBtnCustom.MouseButton1Click:Connect(function()
    if #userWaypoints==0 then return end
    smoothTP(userWaypoints[#userWaypoints].Pos)
end)

--================ TP TAB ===================
local function rebuildTeleportsList()
    for _,c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    for cat,wps in pairs(waypoints) do
        local catLabel = Instance.new("TextLabel", listFrame)
        catLabel.Size = UDim2.new(1,0,0,30)
        catLabel.BackgroundColor3 = Color3.fromRGB(40,40,50)
        catLabel.Text = cat
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextColor3 = Color3.fromRGB(200,200,200)
        catLabel.TextScaled = true
        local corner = Instance.new("UICorner", catLabel)
        corner.CornerRadius = UDim.new(0,10)
        for _,wp in ipairs(wps) do
            local b = Instance.new("TextButton", listFrame)
            b.Size = UDim2.new(1,0,0,35)
            b.BackgroundColor3 = Color3.fromRGB(50,50,60)
            b.TextColor3 = (cat=="Selling") and Color3.fromRGB(255,165,0) or Color3.fromRGB(0,170,255)
            b.Text = wp.Name .. " ("..math.floor(wp.Pos.X)..","..math.floor(wp.Pos.Y)..","..math.floor(wp.Pos.Z)..")"
            b.Font = Enum.Font.GothamBold
            b.TextScaled = true
            b.BorderSizePixel = 0
            local corner2 = Instance.new("UICorner", b)
            corner2.CornerRadius = UDim.new(0,8)
            b.MouseButton1Click:Connect(function() smoothTP(wp.Pos) end)
        end
    end
end
rebuildTeleportsList()

--================ OTHER TAB ===================
local function createInputField(labelText, yPos, callback)
    local lbl = Instance.new("TextLabel", otherFrame)
    lbl.Size = UDim2.new(0.4,0,0,30)
    lbl.Position = UDim2.new(0,10,0,yPos)
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.BackgroundTransparency = 1
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold

    local input = Instance.new("TextBox", otherFrame)
    input.Size = UDim2.new(0.5,0,0,30)
    input.Position = UDim2.new(0.45,0,0,yPos)
    input.PlaceholderText = "Enter value"
    input.Text = ""
    input.TextScaled = true
    input.ClearTextOnFocus = false
    input.BackgroundColor3 = Color3.fromRGB(50,50,60)
    input.TextColor3 = Color3.new(1,1,1)
    local corner = Instance.new("UICorner", input)
    corner.CornerRadius = UDim.new(0,5)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(input.Text)
            if val then
                callback(val)
            end
        end
    end)
end

createInputField("Jump Strength", 10, function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = val
    end
end)
createInputField("Walk Speed", 60, function(val)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = val
    end
end)
createInputField("Fly Speed", 110, function(val)
    flySpeed = val
end)

-- Fly Status + Indicator
local flyFrame = Instance.new("Frame", otherFrame)
flyFrame.Size = UDim2.new(0.9,0,0,30)
flyFrame.Position = UDim2.new(0.05,0,0,160)
flyFrame.BackgroundTransparency = 1

local flyIndicator = Instance.new("Frame", flyFrame)
flyIndicator.Size = UDim2.new(0,20,0,20)
flyIndicator.Position = UDim2.new(0,0,0,5)
flyIndicator.BackgroundColor3 = Color3.fromRGB(255,0,0)
local cornerIndicator = Instance.new("UICorner", flyIndicator)
cornerIndicator.CornerRadius = UDim.new(0,5)

local flyStatus = Instance.new("TextLabel", flyFrame)
flyStatus.Size = UDim2.new(1,0,1,0)
flyStatus.Position = UDim2.new(0,30,0,0)
flyStatus.Text = "Fly: OFF"
flyStatus.TextColor3 = Color3.fromRGB(255,255,255)
flyStatus.BackgroundTransparency = 1
flyStatus.TextScaled = true
flyStatus.Font = Enum.Font.GothamBold

-- Fly/GUI instructions text
local instructions = Instance.new("TextLabel", otherFrame)
instructions.Size = UDim2.new(0.9,0,0,40)
instructions.Position = UDim2.new(0.05,0,0,200)
instructions.Text = "Fly (Z)\nShow/Hide GUI (Insert)"
instructions.TextColor3 = Color3.fromRGB(200,200,200)
instructions.BackgroundTransparency = 1
instructions.TextScaled = true
instructions.TextWrapped = true
instructions.Font = Enum.Font.Gotham

-- Unload Script
local unloadBtn = Instance.new("TextButton", otherFrame)
unloadBtn.Size = UDim2.new(0.9,0,0,35)
unloadBtn.Position = UDim2.new(0.05,0,0,250)
unloadBtn.Text = "Unload Script"
unloadBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
unloadBtn.TextColor3 = Color3.new(1,1,1)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextScaled = true
local cornerUnload = Instance.new("UICorner", unloadBtn)
cornerUnload.CornerRadius = UDim.new(0,8)

local confirmBtn
unloadBtn.MouseButton1Click:Connect(function()
    if confirmBtn and confirmBtn.Parent then confirmBtn:Destroy() end
    confirmBtn = Instance.new("TextButton", otherFrame)
    confirmBtn.Size = UDim2.new(0.5,0,0,30)
    confirmBtn.Position = UDim2.new(0.25,0,0,295)
    confirmBtn.Text = "Confirm Unload"
    confirmBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
    confirmBtn.TextColor3 = Color3.new(1,1,1)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextScaled = true
    local cornerC = Instance.new("UICorner", confirmBtn)
    cornerC.CornerRadius = UDim.new(0,8)
    confirmBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        if bv then bv:Destroy() end
        flying = false
    end)
end)

--================ KEYBINDS ===================
UserInputService.InputBegan:Connect(function(input,gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Z then
            flying = not flying
            if flying then
                flyStatus.Text = "Fly: ON"
                flyIndicator.BackgroundColor3 = Color3.fromRGB(0,255,0)
                local root = getRoot()
                if root then
                    bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    bv.Velocity = Vector3.new(0,0,0)
                    bv.Parent = root
                end
            else
                flyStatus.Text = "Fly: OFF"
                flyIndicator.BackgroundColor3 = Color3.fromRGB(255,0,0)
                if bv then bv:Destroy() end
            end
        elseif input.KeyCode == Enum.KeyCode.Insert then
            frame.Visible = not frame.Visible
        end
    end
end)

--================ FLY MOVEMENT ===================
RunService.RenderStepped:Connect(function()
    if flying and bv then
        local root=getRoot()
        if root then
            local cam=workspace.CurrentCamera
            local dir=Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
            if dir.Magnitude>0 then dir=dir.Unit end
            bv.Velocity=dir*flySpeed
        end
    end
end)
