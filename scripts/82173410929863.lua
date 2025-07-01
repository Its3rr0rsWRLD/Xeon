local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/Its3rr0rsWRLD/Rayfield/refs/heads/main/source.lua'))()

local suggestedGameID = 82173410929863
local currentGameID = game.PlaceId
local walkspeed = 16

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
		Name = "Xeon | Blob Eating Simulator",
		LoadingTitle = "Xeon Loading",
		LoadingSubtitle = "Blob Eating Simulator",
		Theme = "Amethyst",
		ConfigurationSaving = {
			Enabled = true,
			FolderName = "Xeon",
			FileName = "BlobEatingSim3"
		},
		Discord = {
			Enabled = false,
			Invite = "",
			RememberJoins = true
		},
		KeySystem = false
	})

	local Tab = Window:CreateTab("Menu", "home")
	local Section = Tab:CreateSection("Settings")

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
						local success, err = pcall(function()
							local player = game.Players.LocalPlayer
							local character = player.Character or player.CharacterAdded:Wait()
							local humanoid = character:WaitForChild("Humanoid")

							local foodFolder = game.Workspace.Game:WaitForChild("Food")

							for _, food in pairs(foodFolder:GetChildren()) do
								if not AutoFarmToggle then break end
								if food:IsA("Model") then
									local hitbox = food:FindFirstChild("Hitbox")
									if hitbox and hitbox:IsA("BasePart") then
										local offsetCFrame = hitbox.CFrame * CFrame.new(0, 0, 16)
										character:SetPrimaryPartCFrame(offsetCFrame)
										humanoid:MoveTo(hitbox.Position)
										humanoid.MoveToFinished:Wait()
										wait(0.1)
									end
								end
							end
							wait(0.1)
						end)
						if not success then
							print("[Xeon] Error in Autofarm: ", err)
						end
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
