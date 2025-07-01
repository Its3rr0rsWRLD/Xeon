local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local suggestedGameID = 17240213780
local currentGameID = game.PlaceId
local debugMode = false

function createMainWindow()
	local Window = Rayfield:CreateWindow({
		Name = "Xeon | BlobEatingSim",
		LoadingTitle = "Xeon Loading",
		LoadingSubtitle = "Blob Eating Simulator",
		Theme = "Amethyst",
		ConfigurationSaving = {
			Enabled = true,
			FolderName = "Xeon",
			FileName = "BlobEatingSim"
		},
		Discord = {
			Enabled = false,
			Invite = "",
			RememberJoins = true
		},
		KeySystem = false
	})

	local Tab = Window:CreateTab("Menu", "home")
	local UpdateLog = Window:CreateTab("Update Logs", "scroll-text")

	UpdateLog:CreateLabel("Blob Eating Simulator V1.0.4")
	UpdateLog:CreateLabel("Added Safe Distance")

	local Section = Tab:CreateSection("Auto Farm")

	local AutoFarmToggle = false
	local EatKidsToggle = false
	local SafeDistance = 100

	Tab:CreateSlider({
		Name = "Safe Distance",
		Range = {0, 512},
		Increment = 1,
		Suffix = " Studs",
		CurrentValue = 100,
		Flag = "SafeDistance",
		Callback = function(Value)
			SafeDistance = Value
		end
	})

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
						local blobsFolder = game.Workspace:WaitForChild("Blobs")

						for _, blob in pairs(blobsFolder:GetChildren()) do
							if not AutoFarmToggle then break end
							if blob:IsA("BasePart") then
								local isSafe = true

								for _, otherPlayer in pairs(game.Players:GetPlayers()) do
									if otherPlayer.Name ~= player.Name and game.Workspace:FindFirstChild(otherPlayer.Name) then
										local otherCharacter = game.Workspace[otherPlayer.Name]
										local distance = (otherCharacter.PrimaryPart.Position - blob.Position).Magnitude
										if distance < SafeDistance then
											isSafe = false
											break
										end
									end
								end

								if isSafe then
									character:SetPrimaryPartCFrame(blob.CFrame)
									wait(0.1)
								end
							end
						end

						wait(0.1)
					end
				end)
			end
		end    
	})

	Tab:CreateToggle({
		Name = "Eat Kids",
		CurrentValue = false,
		Flag = "EatKids",
		Callback = function(Value)
			EatKidsToggle = Value
			if EatKidsToggle then
				spawn(function()
					while EatKidsToggle do
						local player = game.Players.LocalPlayer
						local playerName = player.Name
						local playerBlobSize = player.leaderstats.Size.Value

						for _, otherPlayer in pairs(game.Players:GetPlayers()) do
							if not EatKidsToggle then break end
							if otherPlayer.Name ~= playerName and otherPlayer:FindFirstChild("leaderstats") then
								local otherBlobSize = otherPlayer.leaderstats.Size.Value

								if otherBlobSize and otherBlobSize < playerBlobSize then
									local character = player.Character or player.CharacterAdded:Wait()
									character:SetPrimaryPartCFrame(game.Workspace[otherPlayer.Name].Blob.CFrame)
									if debugMode then print("[Xeon] Moved to eat " .. otherPlayer.Name) end
									wait(0.1)
								end
							end
						end

						wait(0.1)
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
