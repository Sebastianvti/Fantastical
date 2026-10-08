local CharacterLoader = {}
CharacterLoader.Sheets = {}
CharacterLoader.AllCharacters = {}
CharacterLoader.Modules = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local StoreHouse = ServerStorage.StoreHouse

local Template = require(script.Template)

function CharacterLoader.GetModules(Modules)
	CharacterLoader.Modules = Modules
end

function CharacterLoader.CharacterAdded(Character)
	warn("Character Loaded")
	print(CharacterLoader.Sheets)
	CharacterLoader.Sheets[Character] = Template

	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end

		if Value.CharacterLoaded then Value.CharacterLoaded(Character) end
		if Value.GetSheet then Value.GetSheet(CharacterLoader.Sheets) end
	end
	table.insert(CharacterLoader.AllCharacters, Character.Head)
end

function CharacterLoader.CharacterDied(Character)
	CharacterLoader.Sheets[Character] = nil

	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end
		
		if Value.CharacterDied then Value.CharacterDied(Character) end
	end

	table.remove(CharacterLoader.AllCharacters, table.find(CharacterLoader.AllCharacters, Character.Head))
end

return CharacterLoader
