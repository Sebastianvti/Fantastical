
local MainServices = {
	Framework = game:GetService("ServerScriptService"),
	Shared = game:GetService("ReplicatedStorage")
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DataStore = require(script.DataStore)
local ProfileStore = require(script.Library.ProfileStore)
local MasterTemplate = require(script.DataStore.Templates.MasterTemplate)

local Cache = {}

local PlayerStore = ProfileStore.New(DataStore.GetStoreName(), MasterTemplate)

for Folder,Service  in MainServices do
	for _,Module in Service[Folder]:GetDescendants() do
			if not Module:IsA("ModuleScript") then continue end

			local success, result = pcall(function()
				return require(Module)
			end)

		if success then
			if type(result) == "function" or Module:GetAttribute("Ignore") then continue end
			
			local ModName = Module.Name
			Cache[ModName] = result
	
			if Cache[ModName].Start then
				print(ModName)
				Cache[ModName].Start()
			end
			
			else
				error("Server failed to load due to a module error.".." This error came from "..(Module.Name))
		end
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