local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local LocalPlayer = Players.LocalPlayer

local Lync = require(Shared.Lync)

local MainServices = {
	Client = StarterPlayer.StarterPlayerScripts,
	Shared = ReplicatedStorage
}

local Cache = {}
local FailModuleByType = {"function"}

Lync.start()
RunService.PostSimulation:Connect(function() Lync.flush() end)
local function PCallResult(Module)
	if Module:GetAttribute("Ignore") then return end

		local success, result = pcall(function()
			return require(Module)
		end)

			if success then
			if table.find(FailModuleByType, type(Module)) then print(Module)  return end

			local ModName = Module.Name
			Cache[ModName] = result

			if Cache[ModName].Start then
				Cache[ModName].Start()
			end
			
		else
			error("Client failed to load due to a module error.".." This error came from "..(Module.Name))
	end

end

local function RequireChildren(Module : ModuleScript)
	for _,Module in Module:GetChildren() do
		if not Module:IsA("ModuleScript") or Module:GetAttribute("Ignore") then continue end

		RequireChildren(Module)
		PCallResult(Module)
	end
end

for Folder,Service  in MainServices do
	for _,Module in Service[Folder]:GetChildren() do
			if not Module:IsA("ModuleScript") and not Module:IsA("Folder") or Module:GetAttribute("Ignore") then continue end
			if Module:IsA("ModuleScript") then PCallResult(Module) end

			RequireChildren(Module)
	end
end

local function CharacterAdded(Character)
	print("Client Spawned")
	for _,Value in Cache do
		if Value.CharacterStart then
			Value.CharacterStart()
		end
	end
end

local function CharacterDied(Character)
	print("Client Died")
end

local function PlayerAdded(player)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

	if player.Character then
		task.defer(CharacterAdded, player.Character)
	end 
	player.CharacterAdded:Connect(CharacterAdded)
	player.CharacterRemoving:Connect(CharacterDied)
end

for _,player in Players:GetPlayers() do
	task.defer(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

UserInputService.InputBegan:Connect(function(Input, GPE)
	if GPE then return end
	if Input.KeyCode == Enum.KeyCode.E then
	ReplicatedStorage.RemoteEvent:FireServer("Earth")
	end
	if Input.KeyCode == Enum.KeyCode.T then
	ReplicatedStorage.RemoteEvent:FireServer("Tester")
	end
	if Input.KeyCode == Enum.KeyCode.V then
		ReplicatedStorage.RemoteEvent:FireServer("Venus")
	end
	if Input.KeyCode == Enum.KeyCode.C then
		ReplicatedStorage.RemoteEvent:FireServer("Ceres")
	end
	if Input.KeyCode == Enum.KeyCode.D then
		ReplicatedStorage.SSEvent:FireServer(12222225)
	end
end)

-- test?