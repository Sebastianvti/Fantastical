local CharacterLoader = {}
CharacterLoader.AllCharacters = {}

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local StoreHouse = ServerStorage.StoreHouse
local StatusManager = require(script.Parent.StatusManager)



local function CharacterAdded(Character)
	print("Alive")
	StatusManager.Init(Character)
	table.insert(CharacterLoader.AllCharacters, Character.Head) -- We track the head because only chat service needs this.
end

local function CharacterDied(Character)
	StatusManager.DeInit(Character)
	table.remove(CharacterLoader.AllCharacters, table.find(CharacterLoader.AllCharacters, Character.Head))
end

local function PlayerAdded(player)
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

return CharacterLoader
