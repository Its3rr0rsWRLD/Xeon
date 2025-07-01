
print("[Xeon] Loading...")

local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local currentGameID = game.PlaceId
local gameName = "Unknown Game"

pcall(function()
    local gameInfo = MarketplaceService:GetProductInfo(currentGameID)
    gameName = gameInfo.Name
end)

local function loadGameScript(gameId)
    local success, result = pcall(function()
        local scriptUrl = 'https://raw.githubusercontent.com/Its3rr0rsWRLD/Xeon/main/scripts/' .. gameId .. '.lua'
        local scriptContent = game:HttpGet(scriptUrl)
        local loadedScript = loadstring(scriptContent)
        
        if loadedScript then
            loadedScript()
            return true
        end
        return false
    end)
    
    if success and result then
        print("[Xeon] Successfully loaded script for " .. gameName .. " (ID: " .. gameId .. ")")
    else
        print("[Xeon] Failed to load script for Game ID: " .. gameId)
        return false
    end
    return true
end


print("[Xeon] Checking for script for " .. gameName .. " (ID: " .. currentGameID .. ")")

if loadGameScript(currentGameID) then
    print("[Xeon] Script loaded successfully!")
else
    print("[Xeon] No script found for this game. Loading Xeon GUI...")

    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/ae2c7a0513351212d06e5f001a8099af8fb4dafb/source.lua'))()

    local Window = Rayfield:CreateWindow({
        Name = "Xeon Universal",
        LoadingTitle = "Xeon Loading",
        LoadingSubtitle = "No script found for this game",
        Theme = "Amethyst",
        ConfigurationSaving = {
            Enabled = false
        },
        Discord = { Enabled = false },
        KeySystem = false
    })

    local MainTab = Window:CreateTab("Current Game", "gamepad-2")

    MainTab:CreateLabel("Game: " .. gameName, "gamepad", Color3.fromRGB(138, 43, 226))
    MainTab:CreateLabel("Place ID: " .. currentGameID, "hash", Color3.fromRGB(70, 130, 180))
    MainTab:CreateLabel("No script available for this game", "x-circle", Color3.fromRGB(255, 69, 58))

    MainTab:CreateParagraph({
        Title = "Request a Script",
        Content = "This game doesn't have a script yet. Join our Discord to request one or contribute your own!"
    })

    MainTab:CreateButton({
        Name = "Load Anti-AFK Hub",
        Callback = function()
            Window:Destroy()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/GiggleHub/main/scripts/misc/antiafk.lua'))()
        end
    })
end
