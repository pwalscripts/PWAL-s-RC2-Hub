local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

--================ GUI =================--

local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,350,0,400)
frame.Position = UDim2.new(0,20,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true

-- Drop shadow
local shadow = Instance.new("UIStroke", frame)
shadow.Color = Color3.fromRGB(50,50,60)
shadow.Thickness = 2
shadow.Transparency = 0.5

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Waypoint Tool"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(200,200,200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(0.45,-5,0,35)
saveBtn.Position = UDim2.new(0,5,0,50)
saveBtn.Text = "Save Position"
saveBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.AutoButtonColor = false
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextScaled = true
saveBtn.BorderSizePixel = 0

local tpBtn = Instance.new("TextButton", frame)
tpBtn.Size = UDim2.new(0.45,-5,0,35)
tpBtn.Position = UDim2.new(0.5,0,0,50)
tpBtn.Text = "Teleport Last"
tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.AutoButtonColor = false
tpBtn.Font = Enum.Font.Gotham
tpBtn.TextScaled = true
tpBtn.BorderSizePixel = 0

-- Fly status indicator
local flyIndicator = Instance.new("Frame", frame)
flyIndicator.Size = UDim2.new(0,20,0,20)
flyIndicator.Position = UDim2.new(1,-50,0,15)
flyIndicator.BackgroundColor3 = Color3.fromRGB(255,0,0) -- red = off
flyIndicator.BorderSizePixel = 0
flyIndicator.AnchorPoint = Vector2.new(0,0)

local flyLabel = Instance.new("TextLabel", frame)
flyLabel.Size = UDim2.new(0,40,0,20)
flyLabel.Position = UDim2.new(1,-90,0,15)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly"
flyLabel.TextColor3 = Color3.fromRGB(200,200,200)
flyLabel.TextScaled = true
flyLabel.Font = Enum.Font.GothamBold

-- Scrollable area
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(1,-10,1,-100)
listFrame.Position = UDim2.new(0,5,0,95)
listFrame.BackgroundTransparency = 1
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,5)

--================ DATA =================--

local waypoints = {
    Selling = {
        {Name = "Sellpoint", Pos = Vector3.new(937, 29, -695), Permanent = true},
    },
    Mining = {
        {Name = "Cobalt", Pos = Vector3.new(279, -120, 3394), Permanent = true},
        {Name = "Emeralds", Pos = Vector3.new(-7809, 173, -3338), Permanent = true},
        {Name = "Abbysalite", Pos = Vector3.new(-7136, -712, -2544), Permanent = true},
    }
}

local function getRoot()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function smoothTP(pos)
    local root = getRoot()
    local dist = (root.Position - pos).Magnitude
    local t = math.clamp(dist/70, 0.15, 2)
    local tween = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0,3,0))})
    tween:Play()
end

--================ LIST BUILD =================--

local function rebuildList()
    for _,c in pairs(listFrame:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end

    for category, wps in pairs(waypoints) do
        local catLabel = Instance.new("TextLabel", listFrame)
        catLabel.Size = UDim2.new(1,0,0,25)
        catLabel.BackgroundColor3 = Color3.fromRGB(40,40,50)
        catLabel.Text = category
        catLabel.Font = Enum.Font.GothamBold
        catLabel.TextColor3 = Color3.fromRGB(200,200,200)
        catLabel.TextScaled = true
        catLabel.BorderSizePixel = 0

        for i, wp in ipairs(wps) do
            local b = Instance.new("TextButton", listFrame)
            b.Size = UDim2.new(1,0,0,30)
            b.BackgroundColor3 = Color3.fromRGB(60,60,70)
            b.TextColor3 = (category == "Selling") and Color3.fromRGB(255,165,0) or Color3.fromRGB(0,170,255)
            b.TextScaled = true
            b.Font = Enum.Font.Gotham
            b.Text = wp.Name .. " (" .. math.floor(wp.Pos.X)..","..math.floor(wp.Pos.Y)..","..math.floor(wp.Pos.Z)..")"
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.TextXAlignment = Enum.TextXAlignment.Left

            b.MouseButton1Click:Connect(function()
                smoothTP(wp.Pos)
            end)

            if not wp.Permanent then
                b.MouseButton2Click:Connect(function()
                    table.remove(wps,i)
                    rebuildList()
                end)
            end
        end
    end
end

--================ BUTTONS =================--

saveBtn.MouseButton1Click:Connect(function()
    local pos = getRoot().Position
    table.insert(waypoints.Mining, {Name = "WP "..(#waypoints.Mining + 1), Pos = pos, Permanent = false})
    rebuildList()
    saveBtn.Text = "Saved!"
    task.wait(0.8)
    saveBtn.Text = "Save Position"
end)

tpBtn.MouseButton1Click:Connect(function()
    local last
    if #waypoints.Mining > 0 then
        last = waypoints.Mining[#waypoints.Mining]
    elseif #waypoints.Selling > 0 then
        last = waypoints.Selling[#waypoints.Selling]
    else return end
    smoothTP(last.Pos)
end)

--================ FLY SCRIPT =================--

local flying = false
local speed = 50
local bv

local function toggleFly()
    flying = not flying
    flyIndicator.BackgroundColor3 = flying and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    local root = getRoot()
    if flying and root then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = root
    elseif bv then
        bv:Destroy()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Z then
        toggleFly()
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and bv then
        local root = getRoot()
        if root then
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if moveDir.Magnitude > 0 then moveDir = moveDir.Unit * speed end
            bv.Velocity = moveDir
        end
    end
end)

--================ INITIALIZE =================--

rebuildList()
print("Waypoint GUI ready with colored text categories and fly indicator text")
