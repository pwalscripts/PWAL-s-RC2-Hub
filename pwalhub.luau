--================ FULL PWAL'S HUB SCRIPT ===================
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
    Selling = {
        {Name="Trees/Ores",Pos=Vector3.new(937,29,-695),Permanent=true},
        {Name="Fishes",Pos=Vector3.new(1635,3,-1271),Permanent=true},
        {Name="Enchant",Pos=Vector3.new(-1855,-650,2268)}, -- green
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

--================ FLY VARIABLES ===================
local flying = false
local flySpeed = 50
local bv
local renderConn, inputConn

--================ FUNCTIONS ===================
local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function smoothTP(pos)
    local root = getRoot()
    local dist = (root.Position - pos).Magnitude
    local t = math.clamp(dist/70,0.15,2)
    TweenService:Create(root,TweenInfo.new(t,Enum.EasingStyle.Linear),{CFrame=CFrame.new(pos+Vector3.new(0,3,0))}):Play()
end

--================ TAB SLIDES ===================
local function slideTab(tabFrame, targetX)
    TweenService:Create(tabFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(targetX,10,0,95)}):Play()
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
local function rebuildUserList()
    for _,c in pairs(newListFrame:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i,wp in ipairs(userWaypoints) do
        local b = Instance.new("TextButton", newListFrame)
        b.Size = UDim2.new(1,0,0,40)
        b.BackgroundColor3 = Color3.fromRGB(50,50,60)
        b.TextColor3 = Color3.fromRGB(0,255,255)
        local pos = wp.Pos
        b.Text = wp.Name.." ("..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)..")"
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.BorderSizePixel = 0
        local corner = Instance.new("UICorner", b)
        corner.CornerRadius = UDim.new(0,8)
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
local corner = Instance.new("UICorner", saveBtn)
corner.CornerRadius = UDim.new(0,8)

local tpBtnCustom = Instance.new("TextButton", customTPFrame)
tpBtnCustom.Size = UDim2.new(0.45,-5,0,50)
tpBtnCustom.Position = UDim2.new(0.5,0,0,5)
tpBtnCustom.Text = "Teleport Last"
tpBtnCustom.BackgroundColor3 = Color3.fromRGB(60,60,70)
tpBtnCustom.TextColor3 = Color3.new(1,1,1)
tpBtnCustom.Font = Enum.Font.GothamBold
tpBtnCustom.TextScaled = true
local corner2 = Instance.new("UICorner", tpBtnCustom)
corner2.CornerRadius = UDim.new(0,8)

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
            if cat=="Selling" then
                if wp.Name=="Enchant" then
                    b.TextColor3 = Color3.fromRGB(0,255,0)
                else
                    b.TextColor3 = Color3.fromRGB(255,165,0)
                end
            elseif cat=="Mining" then
                b.TextColor3 = Color3.fromRGB(0,170,255)
            elseif cat=="Shops" then
                b.TextColor3 = Color3.fromRGB(255,0,0)
            else
                b.TextColor3 = Color3.new(1,1,1)
            end
            b.Text = wp.Name
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
flyInstr.Text = "Fly (Z) | Show/Hide GUI (Insert)"
flyInstr.TextColor3 = Color3.fromRGB(200,200,200)
flyInstr.Font = Enum.Font.Gotham
flyInstr.TextScaled = true

-- Jump, Walk, Fly inputs
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
    local corner = Instance.new("UICorner", input)
    corner.CornerRadius = UDim.new(0,5)
    return input
end

local jumpInput = createInputLabel("Jump Strength",70,20)
local walkInput = createInputLabel("Walk Speed",110,20)
local flyInput = createInputLabel("Fly Speed",150,50)

jumpInput.FocusLost:Connect(function(enter)
    if enter then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local val = tonumber(jumpInput.Text)
            if val then hum.JumpPower = val end
        end
    end
end)
walkInput.FocusLost:Connect(function(enter)
    if enter then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local val = tonumber(walkInput.Text)
            if val then hum.WalkSpeed = val end
        end
    end
end)
flyInput.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(flyInput.Text)
        if val then flySpeed = val end
    end
end)

-- Discord link
local discordLabel = Instance.new("TextLabel", otherFrame)
discordLabel.Size = UDim2.new(1,0,0,25)
discordLabel.Position = UDim2.new(0,0,1,-30)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "https://discord.gg/tzDN6mgzmr"
discordLabel.TextColor3 = Color3.fromRGB(100,255,100)
discordLabel.Font = Enum.Font.GothamBold
discordLabel.TextScaled = true
discordLabel.TextStrokeTransparency = 0.7
discordLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Terminate Script button
local terminateBtn = Instance.new("TextButton", otherFrame)
terminateBtn.Size = UDim2.new(0.6,0,0,40)
terminateBtn.Position = UDim2.new(0.2,0,0,200)
terminateBtn.Text = "Terminate Script"
terminateBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
terminateBtn.TextColor3 = Color3.new(1,1,1)
terminateBtn.Font = Enum.Font.GothamBold
terminateBtn.TextScaled = true
local cornerT = Instance.new("UICorner", terminateBtn)
cornerT.CornerRadius = UDim.new(0,10)

terminateBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    if bv then bv:Destroy() end
    if renderConn then renderConn:Disconnect() end
    if inputConn then inputConn:Disconnect() end
end)

--================ FLY & GUI TOGGLE ===================
inputConn = UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.Z then
        flying = not flying
        flyLabel.Text = "Fly: "..(flying and "ON" or "OFF")
        if flying then
            local root = getRoot()
            bv = Instance.new("BodyVelocity",root)
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.new(0,0,0)
        else
            if bv then bv:Destroy() end
        end
    elseif input.KeyCode==Enum.KeyCode.Insert then
        frame.Visible = not frame.Visible
    end
end)

renderConn = RunService.RenderStepped:Connect(function()
    if flying and bv then
        local root = getRoot()
        local cam = workspace.CurrentCamera
        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0,1,0) end
        if direction.Magnitude > 0 then
            bv.Velocity = direction.Unit*flySpeed
        else
            bv.Velocity = Vector3.new(0,0,0)
        end
    end
end)

print("PWAL'S HUB ready with Enchant teleport and Terminate Script button!")
