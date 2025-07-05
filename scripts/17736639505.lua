local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local actionDelay = 1
local autofarmEnabled = true
local playerTemplate = nil

local Window = Rayfield:CreateWindow({
    Name = "Xeon | Marble Tycoon",
    LoadingTitle = "Xeon Loading",
    LoadingSubtitle = "Autofarm",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Xeon",
        FileName = "Autofarm"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Autofarm", "zap")
MainTab:CreateSection("Autofarm Settings")
MainTab:CreateToggle({
    Name = "Enable Autofarm",
    CurrentValue = autofarmEnabled,
    Flag = "AutofarmEnabled",
    Callback = function(Value) autofarmEnabled = Value end
})
MainTab:CreateButton({
    Name = "Update Plot",
    Callback = function()
        playerTemplate = findPlayerTemplate()
        if playerTemplate then
            Rayfield:Notify({
                Title = "Plot Found",
                Content = "Successfully found your plot!",
                Duration = 3,
                Image = "check"
            })
        else
            Rayfield:Notify({
                Title = "Plot Not Found",
                Content = "Using closest template method",
                Duration = 3,
                Image = "alert-triangle"
            })
        end
    end
})
MainTab:CreateSlider({
    Name = "Autofarm Delay (seconds)",
    Range = {1, 5},
    Increment = 1,
    Suffix = "s",
    CurrentValue = actionDelay,
    Flag = "AutofarmDelay",
    Callback = function(Value) actionDelay = Value end
})

local function getTemplates()
    local templates = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "Template" then
            table.insert(templates, obj)
        end
    end
    return templates
end

local function getMoneyDisplay(template)
    local bank = template:FindFirstChild("Bank")
    if not bank then return nil end
    local displayBase = bank:FindFirstChild("DisplayBase")
    if not displayBase then return nil end
    local display = displayBase:FindFirstChild("Display")
    if not display then return nil end
    local money = display:FindFirstChild("Money")
    if not money then return nil end
    local pad = bank:FindFirstChild("Pad")
    return money, displayBase, pad
end

local function getClosestTemplate()
    local templates = getTemplates()
    local minDist = math.huge
    local closest = nil
    local closestPad = nil
    for _, template in ipairs(templates) do
        local money, displayBase, pad = getMoneyDisplay(template)
        if money and pad then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - pad.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = template
                closestPad = pad
            end
        end
    end
    return closest, closestPad
end

local function findPlayerTemplate()
    local templates = getTemplates()
    local playerName = LocalPlayer.Name
    
    for _, template in ipairs(templates) do
        local ownerSign = template:FindFirstChild("OwnerSign")
        if ownerSign then
            local surfaceGui = ownerSign:FindFirstChild("SurfaceGui")
            if surfaceGui then
                local textLabel = surfaceGui:FindFirstChild("TextLabel")
                if textLabel and textLabel.Text then
                    if string.find(textLabel.Text, playerName) then
                        return template
                    end
                end
            end
        end
    end
    
    return nil
end

local function getCurrentTemplate()
    if playerTemplate then
        return playerTemplate
    end
    
    local template, pad = getClosestTemplate()
    return template
end

local function getMoneyValue(money)
    if money:IsA("TextLabel") or money:IsA("TextButton") then
        return money.Text
    end
    return nil
end

local function tpTo(pos)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function claimMoney()
    local template = getCurrentTemplate()
    if template then
        local money, displayBase, pad = getMoneyDisplay(template)
        if pad then
            tpTo(pad.Position + Vector3.new(0, 5, 0))
        end
    end
end

local function getAllPromptButtons(template)
    local buttons = {}
    for _, obj in ipairs(template:GetDescendants()) do
        if obj:FindFirstChildOfClass("ProximityPrompt") then
            table.insert(buttons, obj)
        end
    end
    return buttons
end

local function buyAnyPromptButton(button)
    local prompt = button:FindFirstChildOfClass("ProximityPrompt")
    if button and button.Position and prompt then
        tpTo(button.Position + Vector3.new(0, 3, 0))
        task.wait(0.5)
        
        if button.BrickColor and button.BrickColor.Name == "Bright green" then
            prompt.Enabled = true
            prompt.HoldDuration = 0.5
            prompt.MaxActivationDistance = 10
            fireproximityprompt(prompt, 0.5)
        end
    end
end

local lastAction = 0

RunService.RenderStepped:Connect(function()
    if not autofarmEnabled then return end
    if tick() - lastAction < actionDelay then return end
    lastAction = tick()
    
    local template = getCurrentTemplate()
    if template then
        local money, _, _ = getMoneyDisplay(template)
        if money then
            claimMoney()
            local buttons = getAllPromptButtons(template)
            for _, button in ipairs(buttons) do
                if button.BrickColor and button.BrickColor.Name == "Bright green" then
                    buyAnyPromptButton(button)
                end
            end
        end
    end
end)