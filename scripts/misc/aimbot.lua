local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local ESPSettings = {
    Enabled = true,
    ShowNames = true,
    ShowBoxes = true,
    ShowTracers = false,
    ShowHealth = true,
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
    TriggerKey = "MouseButton2",
    WallCheck = true
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
    if ESPSettings.TeamCheck or AimbotSettings.TeamCheck then
        return player.Team ~= LocalPlayer.Team
    end
    return true
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
    
    ESPObjects[player].Highlight = nil
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 20
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.fromRGB(0, 0, 0)
    name.Font = Drawing.Fonts.Plex
    name.Transparency = 1
    ESPObjects[player].Name = name
    
    local hpBg = Drawing.new("Circle")
    hpBg.Visible = false
    hpBg.Color = Color3.fromRGB(30, 30, 30)
    hpBg.Filled = true
    hpBg.Radius = 18
    hpBg.Transparency = 0.8
    ESPObjects[player].HPBg = hpBg
    
    local hpText = Drawing.new("Text")
    hpText.Visible = false
    hpText.Color = Color3.fromRGB(0, 255, 0)
    hpText.Size = 16
    hpText.Center = true
    hpText.Outline = true
    hpText.OutlineColor = Color3.fromRGB(0, 0, 0)
    hpText.Font = Drawing.Fonts.Plex
    hpText.Transparency = 1
    ESPObjects[player].HPText = hpText
    
    local debugBox = Drawing.new("Square")
    debugBox.Visible = false
    debugBox.Color = Color3.fromRGB(255, 0, 0)
    debugBox.Thickness = 2
    debugBox.Transparency = 1
    debugBox.Filled = false
    debugBox.Size = Vector2.new(50, 30)
    ESPObjects[player].DebugBox = debugBox
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight and ESPObjects[player].Highlight.Parent then
            ESPObjects[player].Highlight:Destroy()
        end
        for _, obj in pairs(ESPObjects[player]) do
            if obj.Remove then obj:Remove() end
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not ESPSettings.Enabled then
        for player, _ in pairs(ESPObjects) do
            if ESPObjects[player] then
                if ESPObjects[player].Highlight and ESPObjects[player].Highlight.Parent then
                    ESPObjects[player].Highlight.Enabled = false
                end
                for _, obj in pairs(ESPObjects[player]) do
                    if obj.Visible ~= nil then obj.Visible = false end
                end
            end
        end
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            if not ESPObjects[player] then createESP(player) end
            local espData = ESPObjects[player]
            local char = player.Character
            local hrp = char.HumanoidRootPart
            local head = char.Head
            local humanoid = char.Humanoid
            local distance = getDistance(Camera.CFrame.Position, hrp.Position)
            local isEnemyPlayer = isEnemy(player)
            local color = isEnemyPlayer and ESPSettings.EnemyColor or ESPSettings.AllyColor
            
            if not espData.Highlight or not espData.Highlight.Parent or espData.Highlight.Adornee ~= char then
                if espData.Highlight and espData.Highlight.Parent then
                    espData.Highlight:Destroy()
                end
                local highlight = char:FindFirstChild("XeonESPHighlight")
                if highlight then highlight:Destroy() end
                
                highlight = Instance.new("Highlight")
                highlight.Name = "XeonESPHighlight"
                highlight.Adornee = char
                highlight.FillColor = color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Enabled = true
                highlight.Parent = char
                espData.Highlight = highlight
            end
            
            if ESPSettings.TeamCheck and not isEnemyPlayer then
                if espData.Highlight then espData.Highlight.Enabled = false end
                if espData.Name then espData.Name.Visible = false end
                if espData.HPBg then espData.HPBg.Visible = false end
                if espData.HPText then espData.HPText.Visible = false end
                if espData.DebugBox then espData.DebugBox.Visible = false end
            else
                if espData.Highlight then
                    espData.Highlight.Enabled = true
                    espData.Highlight.FillColor = color
                    espData.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                
                local headPos = head.Position + Vector3.new(0, head.Size.Y/2 + 1, 0)
                local headScreen, onScreen = worldToScreen(headPos)
                if onScreen then
                    if ESPSettings.ShowNames and espData.Name then
                        espData.Name.Visible = true
                        espData.Name.Color = color
                        espData.Name.Text = player.Name
                        espData.Name.Position = Vector2.new(headScreen.X, headScreen.Y - 25)
                        espData.Name.Color = Color3.fromRGB(255, 255, 255)
                    else
                        if espData.Name then espData.Name.Visible = false end
                    end
                    
                    if espData.DebugBox then
                        espData.DebugBox.Visible = true
                        espData.DebugBox.Position = Vector2.new(headScreen.X - 25, headScreen.Y - 15)
                        espData.DebugBox.Color = Color3.fromRGB(255, 0, 255)
                    end
                    
                    if ESPSettings.ShowHealth and espData.HPBg and espData.HPText then
                        local hp = math.floor(humanoid.Health)
                        local maxHp = math.floor(humanoid.MaxHealth)
                        local hpText = tostring(hp) .. "/" .. tostring(maxHp)
                        
                        espData.HPBg.Visible = true
                        espData.HPBg.Position = Vector2.new(headScreen.X, headScreen.Y + 10)
                        espData.HPBg.Color = Color3.fromRGB(40, 40, 40)
                        espData.HPBg.Radius = 20
                        espData.HPBg.Transparency = 0.8
                        
                        espData.HPText.Visible = true
                        espData.HPText.Text = hpText
                        espData.HPText.Position = Vector2.new(headScreen.X, headScreen.Y + 10)
                        
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        if healthPercent > 0.6 then
                            espData.HPText.Color = Color3.fromRGB(0, 255, 0)
                        elseif healthPercent > 0.3 then
                            espData.HPText.Color = Color3.fromRGB(255, 255, 0)
                        else
                            espData.HPText.Color = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        if espData.HPBg then espData.HPBg.Visible = false end
                        if espData.HPText then espData.HPText.Visible = false end
                    end
                else
                    if espData.Name then espData.Name.Visible = false end
                    if espData.HPBg then espData.HPBg.Visible = false end
                    if espData.HPText then espData.HPText.Visible = false end
                    if espData.DebugBox then espData.DebugBox.Visible = false end
                end
            end
        else
            removeESP(player)
        end
    end
end

local function isTargetVisible(target)
    if not AimbotSettings.WallCheck then
        return true
    end
    
    if not target or not target.Character or not target.Character:FindFirstChild(AimbotSettings.AimPart) then
        return false
    end
    
    local aimPart = target.Character[AimbotSettings.AimPart]
    local camera = workspace.CurrentCamera
    local startPos = camera.CFrame.Position
    local endPos = aimPart.Position
    local direction = (endPos - startPos)
    
    local filterList = {LocalPlayer.Character}
    
    if target.Character then
        for _, part in pairs(target.Character:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(filterList, part)
            end
        end
        for _, accessory in pairs(target.Character:GetChildren()) do
            if accessory:IsA("Accessory") and accessory:FindFirstChild("Handle") then
                table.insert(filterList, accessory.Handle)
            elseif accessory:IsA("Tool") and accessory:FindFirstChild("Handle") then
                table.insert(filterList, accessory.Handle)
            end
        end
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = filterList
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(startPos, direction, raycastParams)
    
    if not raycastResult then
        return true
    end
    
    local hitPart = raycastResult.Instance
    local hitParent = hitPart.Parent
    
    while hitParent and hitParent ~= workspace do
        if hitParent == target.Character then
            return true
        end
        hitParent = hitParent.Parent
    end
    
    return false
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
                if isEnemy(player) then
                    local screenPos, onScreen = worldToScreen(aimPart.Position)
                    local distance3D = getDistance(Camera.CFrame.Position, aimPart.Position)
                    if onScreen and distance3D <= AimbotSettings.MaxDistance then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local screenDistance = getDistance(Vector3.new(screenPos.X, screenPos.Y, 0), Vector3.new(screenCenter.X, screenCenter.Y, 0))
                        if screenDistance <= AimbotSettings.FOV and screenDistance < closestDistance and isTargetVisible(player) then
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
            end            if TargetLocked then
                if TargetLocked.Character and TargetLocked.Character:FindFirstChild(AimbotSettings.AimPart) and TargetLocked.Character:FindFirstChild("Humanoid") and TargetLocked.Character.Humanoid.Health > 0 then
                    local screenPos, onScreen = worldToScreen(TargetLocked.Character[AimbotSettings.AimPart].Position)
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local screenDistance = getDistance(Vector3.new(screenPos.X, screenPos.Y, 0), Vector3.new(screenCenter.X, screenCenter.Y, 0))
                    if onScreen and screenDistance <= AimbotSettings.FOV and isTargetVisible(TargetLocked) then
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
    Name = "Xeon | Universal ESP & Aimbot",
    LoadingTitle = "Xeon Loading",
    LoadingSubtitle = "Universal ESP & Aimbot",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Xeon",
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
AimbotTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = AimbotSettings.WallCheck,
    Flag = "AimbotWallCheck",
    Callback = function(Value) AimbotSettings.WallCheck = Value end
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
            getgenv().XeonAimbotLoaded = nil
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
                if tostring(k):lower():find("Xeon") or tostring(k):lower():find("aimbot") then
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

local MiscTab = Window:CreateTab("Misc", "list")
MiscTab:CreateSection("Server Management")
MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
MiscTab:CreateButton({
    Name = "Server Hop (Find New Server)",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local success, result = pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            
            local availableServers = {}
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(availableServers, server.id)
                end
            end
            
            if #availableServers > 0 then
                local randomServer = availableServers[math.random(1, #availableServers)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
            else
                Rayfield:Notify({
                    Title = "Server Hop",
                    Content = "No available servers found!",
                    Duration = 3,
                    Image = "alert-triangle"
                })
            end
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Server Hop",
                Content = "Failed to find servers. Rejoining current server...",
                Duration = 3,
                Image = "alert-triangle"
            })
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
})
MiscTab:CreateButton({
    Name = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Rayfield:Notify({
                Title = "Job ID",
                Content = "Copied to clipboard: " .. game.JobId,
                Duration = 3,
                Image = "clipboard"
            })
        else
            Rayfield:Notify({
                Title = "Job ID",
                Content = "Your executor doesn't support clipboard. Job ID: " .. game.JobId,
                Duration = 5,
                Image = "alert-triangle"
            })
        end
    end
})

MiscTab:CreateSection("Server Information")
MiscTab:CreateButton({
    Name = "Show Server Info",
    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        local gameId = game.PlaceId
        local jobId = game.JobId
        
        Rayfield:Notify({
            Title = "Server Information",
            Content = string.format("Players: %d/%d\nPing: %dms\nFPS: %d\nGame ID: %s", 
                playerCount, maxPlayers, ping, fps, tostring(gameId)),
            Duration = 6,
            Image = "info"
        })
    end
})

MiscTab:CreateSection("Player Utilities")
MiscTab:CreateButton({
    Name = "List All Players",
    Callback = function()
        local Players = game:GetService("Players")
        local playerList = {}
        
        for _, player in pairs(Players:GetPlayers()) do
            table.insert(playerList, player.Name)
        end
        
        local playerString = table.concat(playerList, ", ")
        
        if setclipboard then
            setclipboard(playerString)
            Rayfield:Notify({
                Title = "Player List",
                Content = "Copied " .. #playerList .. " players to clipboard",
                Duration = 3,
                Image = "users"
            })
        else
            Rayfield:Notify({
                Title = "Player List",
                Content = "Players (" .. #playerList .. "): " .. (string.len(playerString) > 100 and string.sub(playerString, 1, 100) .. "..." or playerString),
                Duration = 5,
                Image = "users"
            })
        end
    end
})
MiscTab:CreateButton({
    Name = "Clear Chat (Client-Side)",
    Callback = function()
        local StarterGui = game:GetService("StarterGui")
        
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = string.rep("\n", 100);
                Font = Enum.Font.Gotham;
                Color = Color3.fromRGB(255, 255, 255);
                FontSize = Enum.FontSize.Size14;
            })
        end)
        
        Rayfield:Notify({
            Title = "Chat Cleared",
            Content = "Chat has been cleared (client-side only)",
            Duration = 2,
            Image = "message-square"
        })
    end
})

MiscTab:CreateSection("Performance")
MiscTab:CreateButton({
    Name = "Reduce Graphics (Boost FPS)",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace.Terrain
        
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 0
            
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
            
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
        
        Rayfield:Notify({
            Title = "Graphics Reduced",
            Content = "Graphics settings lowered for better FPS",
            Duration = 3,
            Image = "zap"
        })
    end
})
MiscTab:CreateButton({
    Name = "Anti-Lag (Remove Unnecessary Objects)",
    Callback = function()
        local removed = 0
        
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceGui") then
                    obj:Destroy()
                    removed = removed + 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj:Destroy()
                    removed = removed + 1
                elseif obj:IsA("Explosion") or obj:IsA("Sound") then
                    obj:Destroy()
                    removed = removed + 1
                end
            end
        end)
        
        Rayfield:Notify({
            Title = "Anti-Lag Complete",
            Content = "Removed " .. removed .. " unnecessary objects",
            Duration = 3,
            Image = "trash-2"
        })
    end
})