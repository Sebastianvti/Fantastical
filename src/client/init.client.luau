local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared

local LocalPlayer = Players.LocalPlayer
local Lync = require(Shared.Lync)

local MainServices = {
	Client = StarterPlayer.StarterPlayerScripts,
	Shared = ReplicatedStorage
}

local Cache = {}
local FailModuleByType = {"function"}

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

local function RequireChildren(Folder : Folder)
	for _,Module in Folder:GetChildren() do
		if not Module:IsA("ModuleScript") or Module:GetAttribute("Ignore") then continue end
		PCallResult(Module)
	end
end

local function Load()
		for Folder,Service  in MainServices do
			for _,Module in Service[Folder]:GetChildren() do
				if not Module:IsA("ModuleScript") and not Module:IsA("Folder") or Module:GetAttribute("Ignore") then continue end
				if Module:IsA("ModuleScript") then PCallResult(Module) end
				
				RequireChildren(Module)
		end
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

local function PlayerAdded(Player)
	if Player ~= LocalPlayer then return end
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

	if Player.Character then
		task.defer(CharacterAdded, Player.Character)
	end 
	Player.CharacterAdded:Connect(CharacterAdded)
	Player.CharacterRemoving:Connect(CharacterDied)
end

for _,Player in Players:GetPlayers() do
	task.defer(PlayerAdded, Player)
end

Load()
Players.PlayerAdded:Connect(PlayerAdded)

Lync.start()
RunService.PostSimulation:Connect(function() Lync.flush() end)

-- test?