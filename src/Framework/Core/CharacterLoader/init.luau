local Players = game:GetService("Players")

local Core = script.Parent

local DataStore = require(Core.DataStore)
local LoadOrder = require(script.LoadOrder) -- In which order the modules load the character
local Template = require(script.Template)

local CharacterLoader = {}
CharacterLoader.Sheets = {}
CharacterLoader.AllCharacters = {}
CharacterLoader.Modules = {}

function CharacterLoader.GetModules(Modules)
	CharacterLoader.Modules = Modules
end

function CharacterLoader.CharacterAdded(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local Profile = DataStore.GetProfile(Player)
	CharacterLoader.Sheets[Character] = Template

	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end

		if Value.CharacterLoaded then Value.CharacterLoaded(Character, Profile) end
	end

	table.insert(CharacterLoader.AllCharacters, Character.Head)
	warn(Character.Name.."'s Character Loaded")
end

function CharacterLoader.CharacterDied(Character)
	CharacterLoader.Sheets[Character] = nil
	
	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end
		
		if Value.CharacterDied then Value.CharacterDied(Character) end
	end

	table.remove(CharacterLoader.AllCharacters, table.find(CharacterLoader.AllCharacters, Character.Head))
	warn(Character.Name.."'s Character Died")
end

function CharacterLoader.DataLoaded(Player : Player, Profile)
	local Character: Model, Data, Humanoid = Player.Character, Profile.Data, Player.Character.Humanoid

	Character:ScaleTo(Data.Size)
	-- Humanoid:RemoveAccessories() remove accessories is a bit bad

	-- important ones are first going down to least important
	for _,Name in LoadOrder do
		if not CharacterLoader.Modules[Name].CharacterLoad then continue end
		CharacterLoader.Modules[Name].CharacterLoad(Character)
	end
end

return CharacterLoader
