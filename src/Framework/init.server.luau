local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local MainServices = {
	Framework = ServerScriptService,
	Shared = ReplicatedStorage
}

local DataStore = require(script.DataStore)
local ProfileStore = require(script.Library.ProfileStore)
local MasterTemplate = require(script.DataStore.Templates.MasterTemplate)
local Lync = require(Shared.Lync)

local Cache = {}
local FailModuleByType = {"function"}

local PlayerStore = ProfileStore.New(DataStore.GetStoreName(), MasterTemplate)

Lync.start()
RunService.PostSimulation:Connect(function(deltaTimeSim) Lync.flush() end)

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

local function PlayerAdded(Player : Player) -- this is for the master profile, it is not tracked cause its not used the moment you load your character
	
	local Profile = PlayerStore:StartSessionAsync("Player_"..Player.UserId, {
		Cancel = function()
			return Player.Parent ~= Players
		end
	})

	if Profile ~= nil then
			Profile:AddUserId(Player.UserId)
			Profile:Reconcile()

			Profile.OnSessionEnd:Connect(function()
				print("[Data]: Master profile session ended.")
			end)

			if Player.Parent == Players then
				DataStore.New(Player, Profile):StartProfile()
			else
				warn("Player was not parented to Player service")
				Profile:EndSession()
			end

		else
			Player:Kick("Data failed to load.")
	end
end

local function PlayerRemoving(Player : Player)
	local Profile = DataStore.Profiles[Player]
	if not Profile then return end

	Profile:EndSession()
	DataStore.Profiles[Player] = nil
end

for _,Player in Players:GetPlayers() do
	task.spawn(PlayerAdded, Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)