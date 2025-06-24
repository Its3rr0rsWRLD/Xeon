local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local AntiAFKEnabled = true
local MethodEnabled = {
    VirtualInput = true,
    MouseMovement = false,
    KeyPress = false,
    WalkAround = false
}
local Statistics = {
    TimeActive = 0,
    KicksPrevented = 0,
    StartTime = tick()
}

local RyzorHubWindow = Rayfield:CreateWindow({
    Name = "⚡ Ryzor Hub - Anti-AFK",
    LoadingTitle = "Anti-AFK Loading",
    LoadingSubtitle = "Premium Anti-AFK Suite",
    Theme = "Ocean",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ryzor",
        FileName = "AntiAFK_Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

local AntiAFKTab = RyzorHubWindow:CreateTab("🛡️ Anti-AFK", "shield-check")
local StatsTab = RyzorHubWindow:CreateTab("📊 Statistics", "bar-chart-3")
local MethodsTab = RyzorHubWindow:CreateTab("⚙️ Methods", "settings")
local InfoTab = RyzorHubWindow:CreateTab("ℹ️ Information", "info")

local MainSection = AntiAFKTab:CreateSection("Anti-AFK Controls")
local StatusLabel = AntiAFKTab:CreateLabel("Status: Active", "activity", Color3.fromRGB(0, 255, 127))

local MainToggle = AntiAFKTab:CreateToggle({
    Name = "Enable Anti-AFK",
    CurrentValue = true,
    Flag = "MainToggle",
    Callback = function(Value)
        AntiAFKEnabled = Value
        if Value then
            StatusLabel:Set("Status: Active", "activity", Color3.fromRGB(0, 255, 127))
        else
            StatusLabel:Set("Status: Disabled", "x-circle", Color3.fromRGB(255, 69, 58))
        end
    end
})

local MethodSection = MethodsTab:CreateSection("Anti-AFK Methods")

local VirtualInputToggle = MethodsTab:CreateToggle({
    Name = "Virtual Input Method",
    CurrentValue = true,
    Flag = "VirtualInput",
    Callback = function(Value)
        MethodEnabled.VirtualInput = Value
    end
})

local MouseMovementToggle = MethodsTab:CreateToggle({
    Name = "Mouse Movement",
    CurrentValue = false,
    Flag = "MouseMovement",
    Callback = function(Value)
        MethodEnabled.MouseMovement = Value
    end
})

local KeyPressToggle = MethodsTab:CreateToggle({
    Name = "Random Key Press",
    CurrentValue = false,
    Flag = "KeyPress",
    Callback = function(Value)
        MethodEnabled.KeyPress = Value
    end
})

local WalkToggle = MethodsTab:CreateToggle({
    Name = "Random Walking",
    CurrentValue = false,
    Flag = "WalkAround",
    Callback = function(Value)
        MethodEnabled.WalkAround = Value
    end
})

local StatsSection = StatsTab:CreateSection("Session Statistics")
local TimeLabel = StatsTab:CreateLabel("Time Active: 0m 0s")
local KicksLabel = StatsTab:CreateLabel("Kicks Prevented: 0")
local UptimeLabel = StatsTab:CreateLabel("Uptime: 0m 0s")

local ResetStatsButton = StatsTab:CreateButton({
    Name = "Reset Statistics",
    Callback = function()
        Statistics.TimeActive = 0
        Statistics.KicksPrevented = 0
        Statistics.StartTime = tick()
        
        Rayfield:Notify({
            Title = "Statistics Reset",
            Content = "All statistics have been reset to zero.",
            Duration = 3,
            Image = "refresh-cw"
        })
    end
})

local InfoSection = InfoTab:CreateSection("About Anti-AFK")

InfoTab:CreateParagraph({
    Title = "How it works",
    Content = "This script prevents Roblox from detecting you as idle by simulating user input. Multiple methods are available to ensure maximum effectiveness while remaining undetected."
})

InfoTab:CreateParagraph({
    Title = "Methods Explained",
    Content = "• Virtual Input: Uses Roblox's VirtualUser service (Most reliable)\n• Mouse Movement: Moves mouse slightly\n• Key Press: Simulates random key presses\n• Walking: Makes character move randomly"
})

InfoTab:CreateDivider()
InfoTab:CreateLabel("Made for Ryzor Hub", "heart", Color3.fromRGB(255, 105, 180))

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    seconds = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, seconds)
    else
        return string.format("%dm %ds", minutes, seconds)
    end
end

local function updateStatistics()
    local currentTime = tick()
    local uptime = currentTime - Statistics.StartTime
    
    TimeLabel:Set("Time Active: " .. formatTime(Statistics.TimeActive))
    KicksLabel:Set("Kicks Prevented: " .. Statistics.KicksPrevented)
    UptimeLabel:Set("Uptime: " .. formatTime(uptime))
end

local function performAntiAFK()
    if not AntiAFKEnabled then return end
    
    if MethodEnabled.VirtualInput then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
    
    if MethodEnabled.MouseMovement then
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local camera = workspace.CurrentCamera
            if camera then
                local currentCFrame = camera.CFrame
                local randomX = math.rad(math.random(-1, 1) * 0.1)
                local randomY = math.rad(math.random(-1, 1) * 0.1)
                camera.CFrame = currentCFrame * CFrame.Angles(randomX, randomY, 0)
                wait(0.1)
                camera.CFrame = currentCFrame
            end
        end
    end
    
    if MethodEnabled.KeyPress then
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local humanoid = Player.Character.Humanoid
            local keys = {"Forward", "Backward", "Left", "Right"}
            local randomKey = keys[math.random(#keys)]
            
            if randomKey == "Forward" then
                humanoid:Move(Vector3.new(0, 0, -0.1))
            elseif randomKey == "Backward" then
                humanoid:Move(Vector3.new(0, 0, 0.1))
            elseif randomKey == "Left" then
                humanoid:Move(Vector3.new(-0.1, 0, 0))
            elseif randomKey == "Right" then
                humanoid:Move(Vector3.new(0.1, 0, 0))
            end
            
            wait(0.1)
            humanoid:Move(Vector3.new(0, 0, 0))
        end
    end
    
    if MethodEnabled.WalkAround and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local humanoid = Player.Character.Humanoid
        local rootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            local directions = {
                Vector3.new(5, 0, 0),
                Vector3.new(-5, 0, 0),
                Vector3.new(0, 0, 5),
                Vector3.new(0, 0, -5),
                Vector3.new(3, 0, 3),
                Vector3.new(-3, 0, -3)
            }
            local randomDirection = directions[math.random(#directions)]
            local targetPosition = rootPart.Position + randomDirection
            
            humanoid:MoveTo(targetPosition)
            
            spawn(function()
                wait(1)
                humanoid:MoveTo(rootPart.Position)
            end)
        end
    end
end

Player.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        
        Statistics.KicksPrevented = Statistics.KicksPrevented + 1
        
        StatusLabel:Set("Prevented kick! Back to active", "shield", Color3.fromRGB(255, 193, 7))
        
        Rayfield:Notify({
            Title = "Kick Prevented!",
            Content = "Successfully prevented an AFK kick. Total prevented: " .. Statistics.KicksPrevented,
            Duration = 5,
            Image = "shield-check"
        })
        
        spawn(function()
            wait(3)
            if AntiAFKEnabled then
                StatusLabel:Set("Status: Active", "activity", Color3.fromRGB(0, 255, 127))
            end
        end)
    end
end)

spawn(function()
    while true do
        wait(1)
        if AntiAFKEnabled then
            Statistics.TimeActive = Statistics.TimeActive + 1
        end
        updateStatistics()
        
        if Statistics.TimeActive % 30 == 0 and AntiAFKEnabled then
            performAntiAFK()
        end
    end
end)

spawn(function()
    while true do
        wait(math.random(15, 25))
        if AntiAFKEnabled then
            performAntiAFK()
        end
    end
end)

Rayfield:Notify({
    Title = "Anti-AFK Loaded!",
    Content = "Ryzor Hub Anti-AFK system is now active and protecting you from kicks!",
    Duration = 6,
    Image = "shield-check"
})

print("Ryzor Hub Anti-AFK Script Loaded Successfully!")
print("Features:")
print("• Multiple anti-AFK methods")
print("• Real-time statistics")
print("• Configurable settings")
print("• Beautiful Rayfield UI")