-- Ryzor Main Menu with Rayfield UI
-- Universal script loader and hub system
-- Made by Its3rr0rsWRLD
print("⚔️ Loading Ryzor...")

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local currentGameID = game.PlaceId
local Player = Players.LocalPlayer
local gameName = "Unknown Game"
local gameCreator = "Unknown Creator"

pcall(function()
    local gameInfo = MarketplaceService:GetProductInfo(currentGameID)
    gameName = gameInfo.Name
    gameCreator = gameInfo.Creator.Name
end)

local supportedGames = {}
local isLoadingGames = true

local function loadAvailableGames()
    local success, result = pcall(function()
        local repoUrl = 'https://api.github.com/repos/Its3rr0rsWRLD/Ryzor/contents/scripts'
        local response = game:HttpGet(repoUrl)
        local data = HttpService:JSONDecode(response)
        
        local gameCount = 0
        for _, item in ipairs(data) do
            if item.type == "file" and item.name:match("%.lua$") then
                local gameId = item.name:match("^(%d+)%.lua$")
                if gameId then
                    gameId = tonumber(gameId)
                    if gameId then
                        local gameInfo = nil
                        local gameSuccess = pcall(function()
                            gameInfo = MarketplaceService:GetProductInfo(gameId)
                        end)
                        
                        if gameSuccess and gameInfo then
                            supportedGames[gameId] = {
                                name = gameInfo.Name,
                                creator = gameInfo.Creator.Name,
                                category = "Loaded",
                                hasScript = true,
                                fileUrl = item.download_url
                            }
                            gameCount = gameCount + 1
                        else
                            supportedGames[gameId] = {
                                name = "Game ID: " .. gameId,
                                creator = "Unknown",
                                category = "Unknown",
                                hasScript = true,
                                fileUrl = item.download_url
                            }
                            gameCount = gameCount + 1
                        end
                    end
                end
            end
        end
        
        return gameCount
    end)
    
    isLoadingGames = false
    return success, result
end

local function checkGameScript(gameId)
    if isLoadingGames then
        return false
    end
    return supportedGames[gameId] ~= nil
end

local function categorizeGame(gameName)
    local name = gameName:lower()
    
    if name:find("simulator") then
        return "🎮 Simulator"
    elseif name:find("tycoon") then
        return "🏭 Tycoon"
    elseif name:find("obby") or name:find("obstacle") then
        return "🏃 Obby"
    elseif name:find("murder") or name:find("mm2") then
        return "🔪 Mystery"
    elseif name:find("blox fruit") or name:find("fighting") or name:find("combat") then
        return "⚔️ Fighting"
    elseif name:find("jailbreak") or name:find("prison") or name:find("mad city") then
        return "🚓 Action"
    elseif name:find("adopt") or name:find("roleplay") or name:find("rp") then
        return "👨‍👩‍👧‍👦 Roleplay"
    elseif name:find("arsenal") or name:find("fps") or name:find("gun") then
        return "🔫 FPS"
    elseif name:find("tower") or name:find("defense") or name:find("strategy") then
        return "🏰 Strategy"
    elseif name:find("racing") or name:find("car") or name:find("drive") then
        return "🏎️ Racing"
    else
        return "📁 Other"
    end
end

local function loadGameScript(gameId)
    local success, result = pcall(function()
        local gameData = supportedGames[gameId]
        local scriptUrl
        
        if gameData and gameData.fileUrl then
            scriptUrl = gameData.fileUrl
        else
            scriptUrl = 'https://raw.githubusercontent.com/Its3rr0rsWRLD/Ryzor/main/scripts/' .. gameId .. '.lua'
        end
        
        local scriptContent = game:HttpGet(scriptUrl)
        local loadedScript = loadstring(scriptContent)
        
        if loadedScript then
            loadedScript()
            return true
        end
        return false
    end)
    
    if success and result then
        Rayfield:Notify({
            Title = "Script Loaded!",
            Content = "Successfully loaded script for " .. (supportedGames[gameId] and supportedGames[gameId].name or "Game ID: " .. gameId),
            Duration = 5,
            Image = "check-circle"
        })
    else
        Rayfield:Notify({
            Title = "Load Failed",
            Content = "Failed to load script for Game ID: " .. gameId,
            Duration = 5,
            Image = "x-circle"
        })
    end
end

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "🎭 Ryzor Universal",
    LoadingTitle = "Ryzor Loading",
    LoadingSubtitle = "Universal Game Hub",
    Theme = "Amethyst",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Ryzor",
        FileName = "MainHub_Config"
    },    Discord = {
        Enabled = true,
        Invite = "your-discord-invite",
        RememberJoins = true
    },
    KeySystem = false
})

local CurrentGameTab = Window:CreateTab("🎮 Current Game", "gamepad-2")

local AllGamesTab = Window:CreateTab("📋 All Games", "list")

local RyzorTab = Window:CreateTab("⚡ Ryzor Hub", "zap")

local SettingsTab = Window:CreateTab("⚙️ Settings", "settings")

local CurrentGameSection = CurrentGameTab:CreateSection("Current Game Information")

CurrentGameTab:CreateLabel("🎯 Game: " .. gameName, "gamepad", Color3.fromRGB(138, 43, 226))
CurrentGameTab:CreateLabel("👨‍💻 Creator: " .. gameCreator, "user", Color3.fromRGB(255, 165, 0))
CurrentGameTab:CreateLabel("🆔 Place ID: " .. currentGameID, "hash", Color3.fromRGB(70, 130, 180))

CurrentGameTab:CreateDivider()

local LoadingLabel = CurrentGameTab:CreateLabel("🔄 Loading available scripts...", "loader", Color3.fromRGB(255, 193, 7))

spawn(function()
    print("🔍 Scanning GitHub repository for available scripts...")
    local success, gameCount = loadAvailableGames()
    
    if success then
        print("✅ Found " .. gameCount .. " game scripts in repository!")
        LoadingLabel:Set("✅ Loaded " .. gameCount .. " available scripts", "check-circle", Color3.fromRGB(0, 255, 127))
        
        local hasCurrentGameScript = checkGameScript(currentGameID)
        local gameInfo = supportedGames[currentGameID]
        
        if hasCurrentGameScript or gameInfo then
            local scriptSection = CurrentGameTab:CreateSection("Available Scripts")
            
            if gameInfo then
                local category = categorizeGame(gameInfo.name)
                CurrentGameTab:CreateLabel("✅ " .. gameInfo.name .. " [" .. category .. "]", "check-circle", Color3.fromRGB(0, 255, 127))
                CurrentGameTab:CreateLabel("👨‍💻 By: " .. gameInfo.creator, "user", Color3.fromRGB(100, 149, 237))
            else
                CurrentGameTab:CreateLabel("✅ Script Available", "check-circle", Color3.fromRGB(0, 255, 127))
            end
            
            local LoadScriptButton = CurrentGameTab:CreateButton({
                Name = "🚀 Load Script for " .. gameName,
                Callback = function()
                    loadGameScript(currentGameID)
                end
            })
        else
            CurrentGameTab:CreateLabel("❌ No script available for this game", "x-circle", Color3.fromRGB(255, 69, 58))
              CurrentGameTab:CreateParagraph({
                Title = "Request a Script",
                Content = "This game doesn't have a script yet. Join our Discord to request one or contribute your own!"
            })
        end
        
        updateAllGamesTab()
        
    else
        LoadingLabel:Set("❌ Failed to load scripts from repository", "x-circle", Color3.fromRGB(255, 69, 58))
        print("❌ Failed to load games from repository")
    end
end)

local AllGamesSection = AllGamesTab:CreateSection("Supported Games")
local AllGamesLoadingLabel = AllGamesTab:CreateLabel("🔄 Loading games from repository...", "loader", Color3.fromRGB(255, 193, 7))

function updateAllGamesTab()
    AllGamesLoadingLabel:Set("✅ " .. #supportedGames .. " games loaded from repository", "check-circle", Color3.fromRGB(0, 255, 127))
    
    local categories = {}
    for gameId, info in pairs(supportedGames) do
        local category = categorizeGame(info.name)
        if not categories[category] then
            categories[category] = {}
        end
        table.insert(categories[category], {id = gameId, info = info})
    end
    
    local sortedCategories = {}
    for category, _ in pairs(categories) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories)
    
    for _, category in ipairs(sortedCategories) do
        local games = categories[category]
        AllGamesTab:CreateSection(category .. " (" .. #games .. " games)")
        
        table.sort(games, function(a, b) return a.info.name < b.info.name end)
        
        for _, game in ipairs(games) do
            local buttonText = string.format("🎮 %s", game.info.name)
            if game.info.creator ~= "Unknown" then
                buttonText = buttonText .. string.format(" (by %s)", game.info.creator)
            end
            
            local gameButton = AllGamesTab:CreateButton({
                Name = buttonText,
                Callback = function()                    if game.id == currentGameID then
                        loadGameScript(game.id)
                    else
                        Rayfield:Notify({
                            Title = "Switch Required",
                            Content = string.format("This script is for %s (ID: %d). You're currently in %s.", 
                                game.info.name, game.id, gameName),
                            Duration = 7,
                            Image = "info"
                        })
                        
                        local copyButton = AllGamesTab:CreateButton({
                            Name = "📋 Copy " .. game.info.name .. " Game ID",
                            Callback = function()
                                setclipboard(tostring(game.id))
                                Rayfield:Notify({
                                    Title = "ID Copied!",
                                    Content = "Game ID " .. game.id .. " copied to clipboard!",
                                    Duration = 3,
                                    Image = "clipboard"
                                })
                            end
                        })
                    end
                end
            })        end
    end
    
    AllGamesTab:CreateDivider()
    local RefreshButton = AllGamesTab:CreateButton({
        Name = "🔄 Refresh Game List",
        Callback = function()
            Rayfield:Notify({
                Title = "Refreshing...",
                Content = "Scanning repository for new scripts...",
                Duration = 3,
                Image = "refresh-cw"
            })
            
            supportedGames = {}
            isLoadingGames = true
            
            spawn(function()
                local success, gameCount = loadAvailableGames()
                if success then
                    Rayfield:Notify({
                        Title = "Refresh Complete",
                        Content = "Found " .. gameCount .. " game scripts!",
                        Duration = 5,
                        Image = "check-circle"
                    })
                else
                    Rayfield:Notify({
                        Title = "Refresh Failed",
                        Content = "Could not connect to repository",
                        Duration = 5,
                        Image = "x-circle"
                    })
                end
            end)
        end
    })
end

local RyzorMainSection = RyzorTab:CreateSection("⚡ Ryzor Hub")

RyzorTab:CreateParagraph({
    Title = "🌟 Premium Tool Suite",
    Content = "Access advanced universal tools and features that work across multiple games."
})

local LoadRyzorButton = RyzorTab:CreateButton({
    Name = "🚀 Load Anti-AFK Hub",
    Callback = function()
        Window:Destroy()
        
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/GiggleHub/main/scripts/misc/antiafk.lua'))()
        
        Rayfield:Notify({
            Title = "Loading Anti-AFK Hub",
            Content = "Launching dedicated Anti-AFK interface...",
            Duration = 3,
            Image = "zap"
        })
    end
})

local SettingsMainSection = SettingsTab:CreateSection("⚙️ Hub Settings")

local AutoLoadToggle = SettingsTab:CreateToggle({
    Name = "Auto-load Game Scripts",
    CurrentValue = false,
    Flag = "AutoLoad",
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Auto-load Enabled",
                Content = "Scripts will automatically load when available!",
                Duration = 3,
                Image = "check"
            })
        end
    end
})

local ThemeDropdown = SettingsTab:CreateDropdown({
    Name = "UI Theme",
    Options = {"Default", "Ocean", "AmberGlow", "Light", "Amethyst", "Green", "Bloom", "DarkBlue", "Serenity"},
    CurrentOption = {"Amethyst"},
    Flag = "UITheme",
    Callback = function(Option)
        Window.ModifyTheme(Option[1])
        Rayfield:Notify({
            Title = "Theme Changed",
            Content = "UI theme changed to " .. Option[1],
            Duration = 3,
            Image = "palette"
        })
    end
})

local NotificationToggle = SettingsTab:CreateToggle({
    Name = "Show Notifications",
    CurrentValue = true,
    Flag = "Notifications",
    Callback = function(Value)
    end
})

spawn(function()
    wait(5)
    
    local hasCurrentGameScript = checkGameScript(currentGameID)
    if hasCurrentGameScript then
        local gameData = supportedGames[currentGameID]
        local gameName = gameData and gameData.name or "this game"
        
        Rayfield:Notify({
            Title = "🎭 Ryzor Ready!",
            Content = "Script available for " .. gameName .. "! Check the Current Game tab.",
            Duration = 8,
            Image = "gamepad-2"
        })
    else
        Rayfield:Notify({
            Title = "🎭 Ryzor Loaded!",
            Content = "Welcome to Ryzor! Found " .. (#supportedGames > 0 and #supportedGames or "several") .. " available scripts. Explore Ryzor Hub for universal tools!",
            Duration = 6,
            Image = "star"
        })
    end
end)

print("🎭 Ryzor loaded successfully!")
print("📊 Current Game: " .. gameName .. " (ID: " .. currentGameID .. ")")
print("🔍 Dynamically loading scripts from GitHub repository...")
print("✨ Features loaded: Main Hub, Ryzor Hub, Universal Tools")
print("🔗 Discord: Join our community for updates and support!")
