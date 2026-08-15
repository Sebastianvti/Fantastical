local CharacterLoader = {}

local Players = game:GetService("Players")

local StatusManager = require(script.Parent.StatusManager)


function CharacterLoader.Start()
	
end

local function CharacterAdded(Character)
	print("Alive")
	StatusManager.Init(Character)
end

local function CharacterDied(Character)
	StatusManager.DeInit(Character)
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
