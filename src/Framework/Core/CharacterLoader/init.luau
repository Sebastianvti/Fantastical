local CharacterLoader = {}
local Template = require(script.Template)

CharacterLoader.Sheets = {}
CharacterLoader.AllCharacters = {}
CharacterLoader.Modules = {}

function CharacterLoader.GetModules(Modules)
	CharacterLoader.Modules = Modules
end

function CharacterLoader.CharacterAdded(Character)
	warn("Character Loaded")
	CharacterLoader.Sheets[Character] = Template

	for Module,Value in CharacterLoader.Modules do
		if Module == script.Name then continue end

		if Value.CharacterLoaded then Value.CharacterLoaded(Character) end
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
