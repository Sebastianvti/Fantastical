local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterGui = game:GetService("StarterGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared

local LocalPlayer = Players.LocalPlayer
local Network = require(Shared.Network)
local Lync = require(Shared.Lync)

local MainServices = {
	Client = StarterPlayer.StarterPlayerScripts,
	Shared = ReplicatedStorage
}

local Modules = {}
local FailModuleByType = {"function"}

local function PCallResult(Module)
	if Module:GetAttribute("Ignore") then return end

		local success, result = pcall(function()
			return require(Module)
		end)

			if success then
			if table.find(FailModuleByType, type(Module)) then print(Module)  return end
			
			local ModName = Module.Name
			Modules[ModName] = result

			if Modules[ModName].Start then
				Modules[ModName].Start()
			elseif Modules[ModName].ClientStart then
				Modules[ModName].ClientStart()
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
	for _,Value in Modules do
		if Value.CharacterAdded then Value.CharacterAdded(Character) end
	end
end

local function CharacterDied(Character)
	print("Client Died")
	for _,Value in Modules do
		if Value.CharacterDied then Value.CharacterDied(Character) end
	end
end

local function PlayerAdded(Player)
	if Player ~= LocalPlayer then return end
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	if Player.Character then task.defer(CharacterAdded, Player.Character) end 

	Player.CharacterAdded:Connect(CharacterAdded)
	Player.CharacterRemoving:Connect(CharacterDied)
end

local function DistributeStats(UserId, Modifiers, OldModifiers)
	for _,Value in Modules do
		if Value.StatsChanged then Value.StatsChanged({Id = UserId, NewStats = Modifiers, OldStats = OldModifiers}) end
	end
end

for _,Player in Players:GetPlayers() do
	task.defer(PlayerAdded, Player)
end

Load()
Players.PlayerAdded:Connect(PlayerAdded)

Lync.start()
RunService.PostSimulation:Connect(function() Lync.flush() end)
Network.Stats:onAdded(DistributeStats)
Network.Stats:onChanged(DistributeStats)


-- test?