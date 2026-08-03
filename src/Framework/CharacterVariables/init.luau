local CharacterVariables = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Template = require(script.Template)
local AbilityLibrary = require(script.AbilityLibrary)
local MethodLibrary = require(script.MethodLibrary)
local Utility = require(script.Utility)

local States = {}


local function GetMethod(Sheet, Ability)
	if not MethodLibrary[Ability.Method] then warn("Method going by "..Ability.Method.." not found.") return end
	
	local Method = MethodLibrary[Ability.Method](Sheet, Ability)
	return Method
end

local function GetAbility(AbilityName)
	if not AbilityLibrary[AbilityName] then return warn("Ability going by "..AbilityName.." not found.") end
	
	local Package = AbilityLibrary[AbilityName]()
	
	return Package
end

local function Dominance(Sheet, AbilityName)
	local Ability = GetAbility(AbilityName)
	Utility.Remove(Ability, Sheet)
	warn(AbilityName.." Was removed due to incompatability.")
end

local function GetIncompats(Ability)
	local Order = {}
	if Ability.IncompatibleGroups and #Ability.IncompatibleGroups ~= 0 then table.insert(Order, "Group") end
	if Ability.Incompatible and #Ability.Incompatible ~= 0 then table.insert(Order, "Singular") end
	return Order
end


local function Compat(Sheet, Ability) -- true if no incompats or dominant, false is incompat
	if #GetIncompats(Ability) == 0 then warn("!!!!") return true end

	for _,Abilities in Ability.Incompatible do
		
		if not table.find(Sheet.Active, Abilities) then continue end
		if not Ability.Dominant then warn("Incompat found, non dominant ability") return false else Dominance(Sheet, Abilities) end
		
	end
	return true
end

local function GetAllGroups()
	for _,Ability in AbilityLibrary do
		if type(Ability) ~= "function" then continue end
		local Element = Ability()
		if not AbilityLibrary.Groups[Element.Group] then AbilityLibrary.Groups[Element.Group] = {} end
		
		table.insert(AbilityLibrary.Groups[Element.Group], Element.Name)
	end
end

local function GetAllNames()
	for _,Ability in AbilityLibrary do
		if type(Ability) ~= "function" then continue end
		local Element = Ability()
		if not AbilityLibrary.NameBank[Element.Name] then AbilityLibrary.NameBank[Element.Name] = {} end

		table.insert(AbilityLibrary.NameBank[Element.Name], Element.Name)
	end
end

local function GetAbilityGroup(AbilityName : string) -- idk why you would need it but here
	local Ability = AbilityLibrary[AbilityName]()
	return Ability.Group
end



function CharacterVariables.Init(Character : Model)

	States[Character] = {}
	States[Character]["Stats"] = Template
	States[Character]["Active"] = {}

	print(States)
end


function CharacterVariables.DeInit(Character : Model)

	States[Character] = nil
	print(States)
end

function CharacterVariables.GetActiveAbilities(Player)
	return States[Player.Character].Active
end

function CharacterVariables.ActivateAbility(Player, AbilityName)
	local Ability = GetAbility(AbilityName)
	
	if not Ability then return end
	
	local Character = Player.Character
	local Sheet = States[Character]
	
	if Ability.Competitive then 
		if not Compat(Sheet, Ability) then warn("incompats found") return end
	end

	local Methods = GetMethod(Sheet, Ability)
	if not Methods then return end

	for Index,Method in Methods do Utility[Method](Ability, Sheet) end
end

function CharacterVariables.Start()
	GetAllGroups()
	GetAllNames()
	print(AbilityLibrary.Groups)
	print(AbilityLibrary.NameBank)
end


ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(CharacterVariables.ActivateAbility)

return CharacterVariables
