local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local ESPSettings = {
    Enabled = false,
    ShowNames = true,
    ShowBoxes = true,
    ShowTracers = false,
    ShowHealth = false,
    ShowHighlight = true,
    TeamCheck = false,
    Color = Color3.fromRGB(255,255,255),
    EnemyColor = Color3.fromRGB(255,0,0),
    AllyColor = Color3.fromRGB(0,255,0),
    MaxDistance = 1000
}

local AimbotSettings = {
    Enabled = false,
    SilentAim = true,
    FOV = 120,
    ShowFOV = true,
    TeamCheck = false,
    AimPart = "Head",
    Smoothness = 0.2,
    MaxDistance = 1000,
    TriggerKey = "MouseButton2"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

local ESPObjects = {}
local FOVCircle = nil
local AimbotConnection = nil
local ESPConnection = nil
local InputConnection = nil
local IsAiming = false
local TargetLocked = nil

local function getTeamColor(player)
    if player.Team and player.TeamColor then
        return player.TeamColor.Color
    end
    return ESPSettings.EnemyColor
end

local function isEnemy(player)
    if not ESPSettings.TeamCheck and not AimbotSettings.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

local function getCharacter(player)
    return player.Character
end

local function getHealth(player)
    local char = getCharacter(player)
    if char and char:FindFirstChild("Humanoid") then
        return math.floor(char.Humanoid.Health)
    end
    return 0
end

local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

local function createESP(player)
    if ESPObjects[player] then return end
    ESPObjects[player] = {}
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESPSettings.Color
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    ESPObjects[player].Box = box
    local healthBarBg = Drawing.new("Square")
    healthBarBg.Visible = false
    healthBarBg.Color = Color3.fromRGB(20, 20, 20)
    healthBarBg.Thickness = 1
    healthBarBg.Filled = true
    healthBarBg.Transparency = 0.8
    ESPObjects[player].HealthBarBg = healthBarBg
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 1
    ESPObjects[player].HealthBar = healthBar
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESPSettings.Color
    tracer.Thickness = 1
    tracer.Transparency = 1
    ESPObjects[player].Tracer = tracer
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = ESPSettings.Color
    name.Size = 16
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.fromRGB(0, 0, 0)
    name.Font = Drawing.Fonts.UI
    name.Transparency = 1
    ESPObjects[player].Name = name
    local distanceText = Drawing.new("Text")
    distanceText.Visible = false
    distanceText.Color = Color3.fromRGB(200, 200, 200)
    distanceText.Size = 12
    distanceText.Center = true
    distanceText.Outline = true
    distanceText.OutlineColor = Color3.fromRGB(0, 0, 0)
    distanceText.Font = Drawing.Fonts.UI
    distanceText.Transparency = 1
    ESPObjects[player].DistanceText = distanceText
    local healthText = Drawing.new("Text")
    healthText.Visible = false
    healthText.Color = ESPSettings.Color
    healthText.Size = 14
    healthText.Center = true
    healthText.Outline = true
    healthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    healthText.Font = Drawing.Fonts.UI
    healthText.Transparency = 1
    ESPObjects[player].HealthText = healthText
end

local function removeESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj.Remove then 
                obj:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not ESPSettings.Enabled then
        for player, _ in pairs(ESPObjects) do
            if ESPObjects[player] then
                for _, obj in pairs(ESPObjects[player]) do
                    obj.Visible = false
                end
            end
        end
        return
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            if not ESPObjects[player] then 
                createESP(player) 
            end
            local espData = ESPObjects[player]
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local head = char.Head
            local humanoid = char.Humanoid
            local distance = getDistance(Camera.CFrame.Position, hrp.Position)
            if distance <= ESPSettings.MaxDistance and humanoid.Health > 0 then
                local isEnemyPlayer = isEnemy(player)
                local color = isEnemyPlayer and ESPSettings.EnemyColor or ESPSettings.AllyColor
                if ESPSettings.TeamCheck and not isEnemyPlayer then
                    for _, obj in pairs(espData) do
                        obj.Visible = false
                    end
                else
                    local screenPos, onScreen = worldToScreen(hrp.Position)
                    local headPos = worldToScreen(head.Position + Vector3.new(0, head.Size.Y/2, 0))
                    local footPos = worldToScreen(hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 2, 0))
                    if onScreen then
                        local boxHeight = math.abs(headPos.Y - footPos.Y)
                        local boxWidth = boxHeight * 0.6
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if ESPSettings.ShowBoxes then
                            espData.Box.Visible = true
                            espData.Box.Color = color
                            espData.Box.Size = Vector2.new(boxWidth, boxHeight)
                            espData.Box.Position = Vector2.new(screenPos.X - boxWidth/2, headPos.Y)
                            espData.Box.Thickness = 2
                            espData.Box.Transparency = 1
                        else
                            espData.Box.Visible = false
                        end
                        if ESPSettings.ShowHealth then
                            local barWidth = boxWidth * 0.8
                            local barHeight = 4
                            local barX = screenPos.X - barWidth/2
                            local barY = footPos.Y + 8
                            espData.HealthBarBg.Visible = true
                            espData.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
                            espData.HealthBarBg.Position = Vector2.new(barX, barY)
                            espData.HealthBarBg.Color = Color3.fromRGB(20, 20, 20)
                            espData.HealthBarBg.Transparency = 0.8
                            espData.HealthBar.Visible = true
                            espData.HealthBar.Size = Vector2.new(barWidth * healthPercent, barHeight)
                            espData.HealthBar.Position = Vector2.new(barX, barY)
                            espData.HealthBar.Transparency = 1
                            if healthPercent > 0.6 then
                                espData.HealthBar.Color = Color3.fromRGB(0, 255, 0)
                            elseif healthPercent > 0.3 then
                                espData.HealthBar.Color = Color3.fromRGB(255, 255, 0)
                            else
                                espData.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                            end
                            espData.HealthText.Visible = true
                            espData.HealthText.Text = math.floor(humanoid.Health) .. "HP"
                            espData.HealthText.Position = Vector2.new(screenPos.X, barY + barHeight + 12)
                            espData.HealthText.Color = espData.HealthBar.Color
                            espData.HealthText.Size = 14
                            espData.HealthText.Transparency = 1
                        else
                            espData.HealthBarBg.Visible = false
                            espData.HealthBar.Visible = false
                            espData.HealthText.Visible = false
                        end
                        if ESPSettings.ShowTracers then
                            espData.Tracer.Visible = true
                            espData.Tracer.Color = color
                            espData.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            espData.Tracer.To = Vector2.new(screenPos.X, footPos.Y)
                            espData.Tracer.Thickness = 2
                            espData.Tracer.Transparency = 1
                        else
                            espData.Tracer.Visible = false
                        end
                        if ESPSettings.ShowNames then
                            espData.Name.Visible = true
                            espData.Name.Color = color
                            espData.Name.Text = player.Name
                            espData.Name.Position = Vector2.new(screenPos.X, headPos.Y - 25)
                            espData.Name.Size = 16
                            espData.Name.Outline = true
                            espData.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
                            espData.Name.Transparency = 1
                            espData.DistanceText.Visible = true
                            espData.DistanceText.Text = "[" .. math.floor(distance) .. "m]"
                            espData.DistanceText.Position = Vector2.new(screenPos.X, headPos.Y - 8)
                            espData.DistanceText.Color = Color3.fromRGB(200, 200, 200)
                            espData.DistanceText.Size = 12
                            espData.DistanceText.Transparency = 1
                        else
                            espData.Name.Visible = false
                            espData.DistanceText.Visible = false
                        end
                    else
                        for _, obj in pairs(espData) do
                            obj.Visible = false
                        end
                    end
                end
            else
                for _, obj in pairs(espData) do
                    obj.Visible = false
                end
            end
        else
            removeESP(player)
        end
    end
end

local function getClosestTarget()
    local closest = nil
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local aimPart = character:FindFirstChild(AimbotSettings.AimPart)
            if humanoid and aimPart and humanoid.Health > 0 then
                if not AimbotSettings.TeamCheck or isEnemy(player) then
                    local screenPos, onScreen = worldToScreen(aimPart.Position)
                    local distance3D = getDistance(Camera.CFrame.Position, aimPart.Position)
                    if onScreen and distance3D <= AimbotSettings.MaxDistance then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local screenDistance = getDistance(Vector3.new(screenPos.X, screenPos.Y, 0), Vector3.new(screenCenter.X, screenCenter.Y, 0))
                        if screenDistance <= AimbotSettings.FOV and screenDistance < closestDistance then
                            closest = player
                            closestDistance = screenDistance
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function aimAt(target)
    if not target or not target.Character or not target.Character:FindFirstChild(AimbotSettings.AimPart) then 
        return 
    end
    local aimPart = target.Character[AimbotSettings.AimPart]
    local targetPosition = aimPart.Position
    local smoothness = math.clamp(AimbotSettings.Smoothness, 0.01, 0.5)
    if AimbotSettings.SilentAim then
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
        local smoothedCFrame = currentCFrame:Lerp(targetCFrame, smoothness)
        Camera.CFrame = smoothedCFrame
    else
        local screenPos, onScreen = worldToScreen(targetPosition)
        if onScreen and mousemoverel then
            local moveX = (screenPos.X - Camera.ViewportSize.X / 2) * smoothness
            local moveY = (screenPos.Y - Camera.ViewportSize.Y / 2) * smoothness
            mousemoverel(moveX, moveY)
        end
    end
end

local function createFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Transparency = 0.8
    FOVCircle.NumSides = 60
    FOVCircle.Radius = AimbotSettings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end

local function updateFOV()
    if AimbotSettings.Enabled and AimbotSettings.ShowFOV then
        if not FOVCircle then
            createFOVCircle()
        end
        FOVCircle.Visible = true
        FOVCircle.Radius = AimbotSettings.FOV
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        if TargetLocked then
            FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        else
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    else
        if FOVCircle then
            FOVCircle.Visible = false
        end
    end
end

local function handleInput(input, processed)
    if processed then return end
    if input.UserInputType.Name == AimbotSettings.TriggerKey then
        IsAiming = true
    end
end

local function handleInputEnd(input, processed)
    if processed then return end
    if input.UserInputType.Name == AimbotSettings.TriggerKey then
        IsAiming = false
        TargetLocked = nil
    end
end

local function startAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
    end
    if InputConnection then
        InputConnection:Disconnect()
    end
    InputConnection = UserInputService.InputBegan:Connect(handleInput)
    UserInputService.InputEnded:Connect(handleInputEnd)
    AimbotConnection = RunService.Heartbeat:Connect(function()
        updateFOV()
        if AimbotSettings.Enabled and IsAiming then
            if not TargetLocked then
                TargetLocked = getClosestTarget()
            end
            if TargetLocked then
                if TargetLocked.Character and TargetLocked.Character:FindFirstChild(AimbotSettings.AimPart) and TargetLocked.Character:FindFirstChild("Humanoid") and TargetLocked.Character.Humanoid.Health > 0 then
                    local screenPos, onScreen = worldToScreen(TargetLocked.Character[AimbotSettings.AimPart].Position)
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local screenDistance = getDistance(Vector3.new(screenPos.X, screenPos.Y, 0), Vector3.new(screenCenter.X, screenCenter.Y, 0))
                    if onScreen and screenDistance <= AimbotSettings.FOV then
                        aimAt(TargetLocked)
                    else
                        TargetLocked = nil
                    end
                else
                    TargetLocked = nil
                end
            end
        else
            TargetLocked = nil
        end
    end)
end

local function startESP()
    if ESPConnection then
        ESPConnection:Disconnect()
    end
    ESPConnection = RunService.Heartbeat:Connect(function()
        updateESP()
    end)
end

startESP()
startAimbot()

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

local Window = Rayfield:CreateWindow({
    Name = "Ryzor | Universal ESP & Aimbot",
    LoadingTitle = "Ryzor Loading",
    LoadingSubtitle = "Universal ESP & Aimbot",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ryzor",
        FileName = "UniversalESP_Aimbot"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

local ESPTab = Window:CreateTab("ESP", "eye")
ESPTab:CreateSection("ESP Settings")
ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = ESPSettings.Enabled,
    Flag = "ESPEnabled",
    Callback = function(Value) ESPSettings.Enabled = Value end
})
ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = ESPSettings.ShowNames,
    Flag = "ESPShowNames",
    Callback = function(Value) ESPSettings.ShowNames = Value end
})
ESPTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = ESPSettings.ShowBoxes,
    Flag = "ESPShowBoxes",
    Callback = function(Value) ESPSettings.ShowBoxes = Value end
})
ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = ESPSettings.ShowHealth,
    Flag = "ESPShowHealth",
    Callback = function(Value) ESPSettings.ShowHealth = Value end
})
ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = ESPSettings.TeamCheck,
    Flag = "ESPTeamCheck",
    Callback = function(Value) ESPSettings.TeamCheck = Value end
})
ESPTab:CreateSlider({
    Name = "Max ESP Distance",
    Range = {100, 3000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = ESPSettings.MaxDistance,
    Flag = "ESPMaxDist",
    Callback = function(Value) ESPSettings.MaxDistance = Value end
})

local AimbotTab = Window:CreateTab("Aimbot", "crosshair")
AimbotTab:CreateSection("Aimbot Settings")
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = AimbotSettings.Enabled,
    Flag = "AimbotEnabled",
    Callback = function(Value) AimbotSettings.Enabled = Value end
})
AimbotTab:CreateToggle({
    Name = "Silent Aim (Safe)",
    CurrentValue = AimbotSettings.SilentAim,
    Flag = "AimbotSilentAim",
    Callback = function(Value) AimbotSettings.SilentAim = Value end
})
AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = AimbotSettings.ShowFOV,
    Flag = "AimbotShowFOV",
    Callback = function(Value) AimbotSettings.ShowFOV = Value end
})
AimbotTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = AimbotSettings.TeamCheck,
    Flag = "AimbotTeamCheck",
    Callback = function(Value) AimbotSettings.TeamCheck = Value end
})
AimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = {AimbotSettings.AimPart},
    Flag = "AimbotAimPart",
    Callback = function(Option) AimbotSettings.AimPart = Option[1] end
})
AimbotTab:CreateDropdown({
    Name = "Trigger Key",
    Options = {"MouseButton1", "MouseButton2", "E", "F", "Q", "C", "X", "Z"},
    CurrentOption = {AimbotSettings.TriggerKey},
    Flag = "AimbotTriggerKey",
    Callback = function(Option) AimbotSettings.TriggerKey = Option[1] end
})
AimbotTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {30, 500},
    Increment = 5,
    Suffix = " px",
    CurrentValue = AimbotSettings.FOV,
    Flag = "AimbotFOV",
    Callback = function(Value) AimbotSettings.FOV = Value end
})
AimbotTab:CreateSlider({
    Name = "Aimbot Smoothness (0 = Slow, 0.5 = Fast)",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = AimbotSettings.Smoothness,
    Flag = "AimbotSmooth",
    Callback = function(Value)
        local smooth = math.clamp(Value, 0.01, 0.5)
        AimbotSettings.Smoothness = smooth
    end
})
AimbotTab:CreateSlider({
    Name = "Aimbot Max Distance",
    Range = {100, 3000},
    Increment = 50,
    Suffix = " studs",
    CurrentValue = AimbotSettings.MaxDistance,
    Flag = "AimbotMaxDist",
    Callback = function(Value) AimbotSettings.MaxDistance = Value end
})

local UtilityTab = Window:CreateTab("Utility", "settings")
UtilityTab:CreateSection("Script Control")
UtilityTab:CreateButton({
    Name = "Unload ESP & Aimbot",
    Callback = function()
        ESPSettings.Enabled = false
        AimbotSettings.Enabled = false
        if AimbotConnection then
            AimbotConnection:Disconnect()
        end
        if ESPConnection then
            ESPConnection:Disconnect()
        end
        if InputConnection then
            InputConnection:Disconnect()
        end
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                if obj.Remove then
                    obj:Remove()
                end
            end
        end
        ESPObjects = {}        if FOVCircle and FOVCircle.Remove then
            FOVCircle:Remove()
        end
        Rayfield:Destroy()
        if getgenv then
            getgenv().RyzorAimbotLoaded = nil
        end
        if script then
            pcall(function() script:Destroy() end)
        end
    end
})
UtilityTab:CreateButton({
    Name = "Force Destroy Script (Hard Unload)",
    Callback = function()
        ESPSettings.Enabled = false
        AimbotSettings.Enabled = false
        if AimbotConnection then
            pcall(function() AimbotConnection:Disconnect() end)
            AimbotConnection = nil
        end
        if ESPConnection then
            pcall(function() ESPConnection:Disconnect() end)
            ESPConnection = nil
        end
        if InputConnection then
            pcall(function() InputConnection:Disconnect() end)
            InputConnection = nil
        end
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                if obj.Remove then
                    pcall(function() obj:Remove() end)
                end
            end
        end
        ESPObjects = {}
        if FOVCircle and FOVCircle.Remove then            pcall(function() FOVCircle:Remove() end)
            FOVCircle = nil
        end
        if Rayfield and Rayfield.Destroy then
            pcall(function() Rayfield:Destroy() end)
        end
        if getgenv then
            local genv = getgenv()
            for k, _ in pairs(genv) do
                if tostring(k):lower():find("ryzor") or tostring(k):lower():find("aimbot") then
                    pcall(function() genv[k] = nil end)
                end
            end
        end
        if setmetatable and getmetatable then
            local mt = getmetatable(game)
            if mt and mt.__index then
                pcall(function() setmetatable(game, nil) end)
            end
        end
        if script then
            pcall(function() script:Destroy() end)
        end
        if getconnections then
            for _,v in ipairs(getconnections(RunService.Heartbeat)) do
                pcall(function() v:Disable() end)
            end
            for _,v in ipairs(getconnections(Players.PlayerRemoving)) do
                pcall(function() v:Disable() end)
            end
        end
        if getgenv and getgenv().Rayfield then
            pcall(function() getgenv().Rayfield = nil end)
        end
        collectgarbage("collect")
    end
})