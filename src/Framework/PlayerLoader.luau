local CharacterLoader = {}

local Players = game:GetService("Players")

local CharacterVariables = require(script.Parent.CharacterVariables)


function CharacterLoader.Start()
	
end

local function CharacterAdded(Character)
	print("Alive")
	-- init anything here that needs to be loaded AFTER character loads
	CharacterVariables.Init(Character)
end

local function CharacterDied(Character)
	CharacterVariables.DeInit(Character)
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
