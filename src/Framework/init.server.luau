
local MainServices = {
	Framework = game:GetService("ServerScriptService"),
	Shared = game:GetService("ReplicatedStorage")
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Data = require(script.Data)
local ProfileStore = require(script.Library.ProfileStore)
local MasterTemplate = require(script.Data.Templates.MasterTemplate)

local Cache = {}

local PlayerStore = ProfileStore.New(Data.GetStoreName(), MasterTemplate)

for Folder,Service  in MainServices do
	for _,Module in Service[Folder]:GetDescendants() do
			if not Module:IsA("ModuleScript") then continue end

			local success, result = pcall(function()
				return require(Module)
			end)

		if success then
			if type(result) == "function" then continue end
			
			local ModName = Module.Name
			Cache[ModName] = result
	
			if Cache[ModName].Start then
				Cache[ModName].Start()
			end
			
			else
				error("Server failed to load due to a module error.".." This error came from "..(Module.Name))
		end
	end
end

local function PlayerAdded(Player : Player)
	
	local Profile = PlayerStore:StartSessionAsync("Player_"..Player.UserId, {
		Cancel = function()
			return Player.Parent ~= Players
		end
	})

	if Profile ~= nil then
			Profile:AddUserId(Player.UserId)
			Profile:Reconcile()

			Profile.OnSessionEnd:Connect(function()
				Data.Profiles[Player] = nil
				Player:Kick("Data error.")
			end)

			if Player.Parent == Players then
				Data.Profiles[Player] = Profile
				Data.LoadCharacter(Player)
			else
				warn("Player was not parented to Player service")
				Profile:EndSession()
			end

		else
			Player:Kick("Data failed to load.")
	end
end

local function PlayerRemoving(Player : Player)
	local Profile = Data.Profiles[Player]
	if not Profile then return end

	Profile:EndSession()
	Data.Profiles[Player] = nil
end

for _,Player in Players:GetPlayers() do
	task.spawn(PlayerAdded, Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)