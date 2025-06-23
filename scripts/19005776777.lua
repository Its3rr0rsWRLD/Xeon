local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local suggestedGameID = 19005776777
local currentGameID = game.PlaceId
local walkspeed = 16
local spawnOffset = 16

spawn(function()
    while true do
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        if humanoid.WalkSpeed ~= walkspeed then
            humanoid.WalkSpeed = walkspeed
        end

        wait(0.1)
    end
end)

function createMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Ryzor | Pyramid Eaters",
        LoadingTitle = "Ryzor Loading",
        LoadingSubtitle = "Pyramid Eaters",
        Theme = "Amethyst",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "Ryzor",
            FileName = "PyramidEaters"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = true
        },
        KeySystem = false
    })

    local Tab = Window:CreateTab("Menu", "home")
    Tab:CreateSection("Settings")

    Tab:CreateSlider({
        Name = "Walkspeed",
        Range = {16, 500},
        Increment = 1,
        Suffix = " WS",
        CurrentValue = walkspeed,
        Flag = "Walkspeed",
        Callback = function(Value)
            walkspeed = Value
        end    
    })
    
    Tab:CreateSlider({
        Name = "Spawn Offset (Studs)",
        Range = {0, 100},
        Increment = 1,
        Suffix = " Offset",
        CurrentValue = spawnOffset,
        Flag = "SpawnOffset",
        Callback = function(Value)
            spawnOffset = Value
        end    
    })

    local AutoFarmToggle = false

    Tab:CreateToggle({
        Name = "Toggle Autofarm",
        CurrentValue = false,
        Flag = "AutoFarm",
        Callback = function(Value)
            AutoFarmToggle = Value
            if AutoFarmToggle then
                spawn(function()
                    while AutoFarmToggle do
                        local player = game.Players.LocalPlayer
                        local character = player.Character or player.CharacterAdded:Wait()
                        local humanoid = character:WaitForChild("Humanoid")

                        local foodFolder = game.Workspace.Game:WaitForChild("Food")
                        local closestFood = nil
                        local closestDistance = math.huge
                        local characterPos = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new(0, 0, 0)

                        for _, food in pairs(foodFolder:GetChildren()) do
                            if food:IsA("Model") and food:FindFirstChild("Hitbox") and food.Hitbox:IsA("BasePart") then
                                local distance = (food.Hitbox.Position - characterPos).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestFood = food
                                end
                            end
                        end

                        if closestFood then
                            local offsetCFrame = closestFood.Hitbox.CFrame * CFrame.new(0, 0, spawnOffset)
                            character:SetPrimaryPartCFrame(offsetCFrame)
                            humanoid:MoveTo(closestFood.Hitbox.Position)
                            humanoid.MoveToFinished:Wait()
                        end

                        wait(0.1)
                    end
                end)
            end
        end    
    })

    local EatOthersToggle = false

    Tab:CreateToggle({
        Name = "Eat Others",
        CurrentValue = false,
        Flag = "EatOthers",
        Callback = function(Value)
            EatOthersToggle = Value
            if EatOthersToggle then
                spawn(function()
                    while EatOthersToggle do
                        local localPlayer = game.Players.LocalPlayer
                        local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                        local localLeaderstats = localPlayer:FindFirstChild("leaderstats")
                        local mySize = 0
                        if localLeaderstats and localLeaderstats:FindFirstChild("Size") then
                            mySize = localLeaderstats.Size.Value
                        end

                        for _, player in pairs(game.Players:GetPlayers()) do
                            if player ~= localPlayer and player.Character and player.Character.PrimaryPart then
                                local theirLeaderstats = player:FindFirstChild("leaderstats")
                                local theirSize = 0
                                if theirLeaderstats and theirLeaderstats:FindFirstChild("Size") then
                                    theirSize = theirLeaderstats.Size.Value
                                end
                                if theirSize < mySize then
                                    local targetCharacter = player.Character
                                    if targetCharacter and targetCharacter.PrimaryPart then
                                        localCharacter:SetPrimaryPartCFrame(targetCharacter.PrimaryPart.CFrame)
                                        wait(0.2)
                                    end
                                end
                            end
                        end

                        wait(0.5)
                    end
                end)
            end
        end
    })

    Tab:CreateButton({
        Name = "Kill Script",
        Callback = function()
            Rayfield:Destroy()
        end
    })
end

if currentGameID ~= suggestedGameID then
    local WarningWindow = Rayfield:CreateWindow({
        Name = "Warning",
        LoadingTitle = "Warning",
        LoadingSubtitle = "Game ID Mismatch",
        Theme = "Amethyst",
        ConfigurationSaving = {
            Enabled = false,
            FolderName = "",
            FileName = ""
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = false
        },
        KeySystem = false
    })
    
    local WarningTab = WarningWindow:CreateTab("Warning", "alert-triangle")
    WarningTab:CreateLabel("This script is made for Game ID " .. suggestedGameID)
    WarningTab:CreateLabel("Current Game ID: " .. currentGameID)
    WarningTab:CreateLabel("Do you want to continue anyway?")
    
    WarningTab:CreateButton({
        Name = "Continue",
        Callback = function()
            createMainWindow()
            WarningWindow:Destroy()
        end
    })
    
    WarningTab:CreateButton({
        Name = "Cancel",
        Callback = function()
            Rayfield:Destroy()
        end
    })
else
    createMainWindow()
end
