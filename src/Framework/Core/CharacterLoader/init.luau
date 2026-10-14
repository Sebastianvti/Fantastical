local Players = game:GetService("Players")

local Core = script.Parent

local DataStore = require(Core.DataStore)
local LoadOrder = require(script.LoadOrder) -- In which order the modules load the character
local Template = require(script.Template)

local CharacterLoader = {}
CharacterLoader.Sheets = {}
CharacterLoader.AllCharacters = {}
CharacterLoader.Modules = {}

local function EditCharacter(Character : Model, Profile : {any})
	Character:ScaleTo(Profile.Data.Size)
end

function CharacterLoader.GetModules(Modules)
	CharacterLoader.Modules = Modules
end

function CharacterLoader.CharacterAdded(Character) -- apologies for the amazing naming conventions. characterinit is for code targetting the character, characterloaded is when all of that is done, so basically just character added
	local Player = Players:GetPlayerFromCharacter(Character)
	local Profile = DataStore.GetProfile(Player)
	CharacterLoader.Sheets[Character] = Template
	EditCharacter(Character, Profile)

	for _,Name in LoadOrder do
		if not CharacterLoader.Modules[Name].CharacterInit then continue end
		CharacterLoader.Modules[Name].CharacterInit(Character)
	end

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


return CharacterLoader
