local CharacterLoader = {}
CharacterLoader.AllCharacters = {}
CharacterLoader.Modules = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local StoreHouse = ServerStorage.StoreHouse

function CharacterLoader.GetModules(Modules)
	CharacterLoader.Modules = Modules
end

function CharacterLoader.CharacterAdded(Character)
	warn("Character Loaded")
	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end

		if Value.CharacterLoaded then Value.CharacterLoaded(Character) end
	end
	table.insert(CharacterLoader.AllCharacters, Character.Head)
end

function CharacterLoader.CharacterDied(Character)
	warn("Character Died")
	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end
		
		if Value.CharacterDied then Value.CharacterDied(Character) end
	end

	table.remove(CharacterLoader.AllCharacters, table.find(CharacterLoader.AllCharacters, Character.Head))
end

return CharacterLoader
