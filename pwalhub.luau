--================== PWAL'S HUB EXECUTOR VERSION ==================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
repeat task.wait() until player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local char = player.Character
local root = char:WaitForChild("HumanoidRootPart")

--================== GUI ==================
local gui = Instance.new("ScreenGui")
gui.Name = "PWALS_HUB"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui") -- Executor safe

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,450,0,500)
frame.Position = UDim2.new(0,20,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,15)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.Text = "PWAL'S HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

--================== TAB BUTTONS ==================
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
local tpBtnTab    = createTabButton("TP", UDim2.new(1/3,0,0,0))
local otherTabBtn = createTabButton("Other", UDim2.new(2/3,0,0,0))

--================== TAB FRAMES ==================
local function createTabFrame()
    local f = Instance.new("Frame", frame)
    f.Size = UDim2.new(1,-20,1,-110)
    f.Position = UDim2.new(0,10,0,95)
    f.BackgroundColor3 = Color3.fromRGB(35,35,40)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)
    return f
end

local customTPFrame = createTabFrame()
local tpFrame       = createTabFrame()
local otherFrame    = createTabFrame()

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
local listFrame    = createScroll(tpFrame,0)

--================== DATA ==================
local userWaypoints = {}
local waypoints = {
    Selling = {
        {Name="Plot1", Pos=Vector3.new(1570,30,-477)},
        {Name="Trees/Ores",Pos=Vector3.new(937,29,-695),Permanent=true},
        {Name="Fishes",Pos=Vector3.new(1635,3,-1271),Permanent=true},
        {Name="Enchant",Pos=Vector3.new(-1855,-650,2268)},
    },
    Mining = {
        {Name="Cobalt",Pos=Vector3.new(279,-120,3394),Permanent=true},
        {Name="Emeralds",Pos=Vector3.new(-7809,173,-3338),Permanent=true},
        {Name="Abbysalite",Pos=Vector3.new(-7136,-712,-2544),Permanent=true},
    },
    Shops = {
        {Name="Furniture Store",Pos=Vector3.new(1172,101,546)},
        {Name="Lush Shop",Pos=Vector3.new(-596,-532,989)},
        {Name="Vi's Logics",Pos=Vector3.new(-5147,59,-2842)},
        {Name="Material Store",Pos=Vector3.new(1068,32,-839)},
        {Name="Dealership",Pos=Vector3.new(664,24,-515)},
        {Name="Default Shop",Pos=Vector3.new(1256,30,-694)},
        {Name="Dynamite Shop",Pos=Vector3.new(1033,263,3911)},
        {Name="Land Agency",Pos=Vector3.new(1357,30,-753)},
        {Name="Nautic Shop",Pos=Vector3.new(1777,3,-1320)},
        {Name="Oil Rig Shop",Pos=Vector3.new(-2295,70,5378)},
    }
}

--================== FUNCTIONS ==================
local function smoothTP(pos)
    root.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

local function slideTab(tabFrame, targetX)
    TweenService:Create(tabFrame,TweenInfo.new(0.3),{Position=UDim2.new(targetX,10,0,95)}):Play()
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

--================== CUSTOM TP ==================
local function rebuildUserList()
    for _,c in pairs(newListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for i,wp in ipairs(userWaypoints) do
        local b = Instance.new("TextButton", newListFrame)
        b.Size = UDim2.new(1,0,0,40)
        b.BackgroundColor3 = Color3.fromRGB(50,50,60)
        b.TextColor3 = Color3.fromRGB(0,255,255)
        b.Text = wp.Name.." ("..math.floor(wp.Pos.X)..","..math.floor(wp.Pos.Y)..","..math.floor(wp.Pos.Z)..")"
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        b.MouseButton1Click:Connect(function() smoothTP(wp.Pos) end)
        b.MouseButton2Click:Connect(function()
            table.remove(userWaypoints,i)
            rebuildUserList()
        end)
    end
end

local saveBtn = Instance.new("TextButton", customTPFrame)
saveBtn.Size = UDim2.new(0.45,-5,0,50)
saveBtn.Position = UDim2.new(0,5,0,5)
saveBtn.Text = "Save Position"
saveBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextScaled = true
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,8)

local tpBtnCustom = Instance.new("TextButton", customTPFrame)
tpBtnCustom.Size = UDim2.new(0.45,-5,0,50)
tpBtnCustom.Position = UDim2.new(0.5,0,0,5)
tpBtnCustom.Text = "Teleport Last"
tpBtnCustom.BackgroundColor3 = Color3.fromRGB(60,60,70)
tpBtnCustom.TextColor3 = Color3.new(1,1,1)
tpBtnCustom.Font = Enum.Font.GothamBold
tpBtnCustom.TextScaled = true
Instance.new("UICorner", tpBtnCustom).CornerRadius = UDim.new(0,8)

saveBtn.MouseButton1Click:Connect(function()
    table.insert(userWaypoints,{Name="WP "..#userWaypoints+1,Pos=root.Position})
    rebuildUserList()
    saveBtn.Text = "Saved!"
    task.wait(0.8)
    saveBtn.Text = "Save Position"
end)
tpBtnCustom.MouseButton1Click:Connect(function()
    if #userWaypoints>0 then smoothTP(userWaypoints[#userWaypoints].Pos) end
end)

--================== TP TAB ==================
local function rebuildTeleportsList()
    for _,c in pairs(listFrame:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end
    for cat,wps in pairs(waypoints) do
        local catLabel = Instance.new("TextLabel", listFrame)
        catLabel.Size = UDim2.new(1,0,0,30)
        catLabel.BackgroundColor3 = Color3.fromRGB(40,40,50)
        catLabel.Text = cat
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextColor3 = Color3.fromRGB(200,200,200)
        catLabel.TextScaled = true
        Instance.new("UICorner", catLabel).CornerRadius = UDim.new(0,10)
        for _,wp in ipairs(wps) do
            local b = Instance.new("TextButton", listFrame)
            b.Size = UDim2.new(1,0,0,35)
            b.BackgroundColor3 = Color3.fromRGB(50,50,60)
            if cat=="Selling" then
                if wp.Name=="Enchant" or wp.Name=="Plot1" then b.TextColor3 = Color3.fromRGB(0,255,0)
                else b.TextColor3 = Color3.fromRGB(255,165,0) end
            elseif cat=="Mining" then b.TextColor3 = Color3.fromRGB(0,170,255)
            elseif cat=="Shops" then b.TextColor3 = Color3.fromRGB(255,0,0)
            else b.TextColor3 = Color3.new(1,1,1) end
            b.Text = wp.Name
            b.Font = Enum.Font.GothamBold
            b.TextScaled = true
            b.BorderSizePixel = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
            b.MouseButton1Click:Connect(function() smoothTP(wp.Pos) end)
        end
    end
end
rebuildTeleportsList()

--================== OTHER TAB ==================
local flyLabel = Instance.new("TextLabel", otherFrame)
flyLabel.Size = UDim2.new(0.4,0,0,30)
flyLabel.Position = UDim2.new(0,5,0,5)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly: OFF"
flyLabel.TextColor3 = Color3.fromRGB(255,255,255)
flyLabel.Font = Enum.Font.GothamBold
flyLabel.TextScaled = true

local flyInstr = Instance.new("TextLabel", otherFrame)
flyInstr.Size = UDim2.new(1,0,0,20)
flyInstr.Position = UDim2.new(0,5,0,40)
flyInstr.BackgroundTransparency = 1
flyInstr.Text = "Fly (Z) | Show/Hide GUI (P)"
flyInstr.TextColor3 = Color3.fromRGB(200,200,200)
flyInstr.Font = Enum.Font.Gotham
flyInstr.TextScaled = true

local tpLastLabel = Instance.new("TextLabel", otherFrame)
tpLastLabel.Size = UDim2.new(1,0,0,20)
tpLastLabel.Position = UDim2.new(0,5,0,65)
tpLastLabel.BackgroundTransparency = 1
tpLastLabel.Text = "TP to last (M)"
tpLastLabel.TextColor3 = Color3.fromRGB(200,200,200)
tpLastLabel.Font = Enum.Font.Gotham
tpLastLabel.TextScaled = true

local function createInputLabel(name,posY,default)
    local lbl = Instance.new("TextLabel", otherFrame)
    lbl.Size = UDim2.new(0.4,0,0,25)
    lbl.Position = UDim2.new(0,5,0,posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true

    local input = Instance.new("TextBox", otherFrame)
    input.Size = UDim2.new(0.5,0,0,25)
    input.Position = UDim2.new(0.45,0,0,posY)
    input.BackgroundColor3 = Color3.fromRGB(60,60,70)
    input.TextColor3 = Color3.new(1,1,1)
    input.Text = tostring(default)
    input.Font = Enum.Font.Gotham
    input.TextScaled = true
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,5)
    return input
end

local jumpInput = createInputLabel("Jump Strength",90,50)
local walkInput = createInputLabel("Walk Speed",130,16)
local flyInput  = createInputLabel("Fly Speed",170,50)

jumpInput.FocusLost:Connect(function(enter)
    if enter and char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then local val = tonumber(jumpInput.Text) if val then hum.JumpPower = val end end end
end)
walkInput.FocusLost:Connect(function(enter)
    if enter and char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then local val = tonumber(walkInput.Text) if val then hum.WalkSpeed = val end end end
end)
flyInput.FocusLost:Connect(function(enter)
    if enter then local val = tonumber(flyInput.Text) if val then flySpeed = val end end
end)

local terminateBtn = Instance.new("TextButton", otherFrame)
terminateBtn.Size = UDim2.new(0.6,0,0,40)
terminateBtn.Position = UDim2.new(0.2,0,0,220)
terminateBtn.Text = "Terminate Script"
terminateBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
terminateBtn.TextColor3 = Color3.new(1,1,1)
terminateBtn.Font = Enum.Font.GothamBold
terminateBtn.TextScaled = true
Instance.new("UICorner", terminateBtn).CornerRadius = UDim.new(0,10)
terminateBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

--================== FLY & HOTKEYS ==================
local flying = false
local flySpeed = 50
local bv

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z then
        flying = not flying
        flyLabel.Text = "Fly: "..(flying and "ON" or "OFF")
        if flying then
            bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = root
        else
            if bv then bv:Destroy() end
        end
    elseif input.KeyCode == Enum.KeyCode.M then
        if #userWaypoints>0 then smoothTP(userWaypoints[#userWaypoints].Pos) end
    elseif input.KeyCode == Enum.KeyCode.P then
        frame.Visible = not frame.Visible
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and bv then
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        local keys = UserInputService.IsKeyDown
        if keys(UserInputService,Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if keys(UserInputService,Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if keys(UserInputService,Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if keys(UserInputService,Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if keys(UserInputService,Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if keys(UserInputService,Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        bv.Velocity = (move.Magnitude>0) and move.Unit*flySpeed or Vector3.new(0,0,0)
    end
end)

print("PWAL'S HUB LOADED - 3 Tabs | Fly: Z | GUI: P | TP Last: M")
