local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local suggestedGameID = 16426855766
local currentGameID = game.PlaceId
local farmSpeed = 0.5
farmSpeed = 1 - farmSpeed

function createMainWindow()
	local Window = Rayfield:CreateWindow({
		Name = "Ryzor | Eat Pizza Simulator",
		LoadingTitle = "Ryzor Loading",
		LoadingSubtitle = "Eat Pizza Simulator",
		Theme = "Amethyst",
		ConfigurationSaving = {
			Enabled = true,
			FolderName = "Ryzor",
			FileName = "EatPizzaSimulator"
		},
		Discord = {
			Enabled = false,
			Invite = "",
			RememberJoins = true
		},
		KeySystem = false
	})

	local Tab = Window:CreateTab("Menu", "home")
	local Section = Tab:CreateSection("Auto Farm")

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

						local orbsFolder = game.Workspace:WaitForChild("Orbs")

						for _, orb in pairs(orbsFolder:GetChildren()) do
							if not AutoFarmToggle then break end
							if orb:IsA("BasePart") then
								character:SetPrimaryPartCFrame(orb.CFrame)
								wait(farmSpeed)
							end
						end

						wait(0.1)
					end
				end)
			end
		end    
	})

	Tab:CreateSlider({
		Name = "Farm Speed",
		Range = {0, 1},
		Increment = 0.01,
		Suffix = "",
		CurrentValue = 0.5,
		Flag = "FarmSpeed",
		Callback = function(Value)
			farmSpeed = 1 - Value
		end    
	})

	Tab:CreateLabel("Lower speeds work better")

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
			WarningWindow:Destroy()
			createMainWindow()
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
