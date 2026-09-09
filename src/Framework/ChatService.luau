local ChatService = {}

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local CharacterLoader = require(script.Parent.CharacterLoader)

local Overlap = OverlapParams.new()
local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude

local function Filter(Text, Player)
	if not Text or Text == "" then return end

	-- Filter the text for the specific player
	local success, filtered = pcall(function()
		return TextService:FilterStringAsync(Text, Player.UserId)
	end)

	if success and filtered then
		local SafeText = filtered:GetNonChatStringForBroadcastAsync()
		return SafeText
	end
end

local function ObserveArea(Character : Model)
    Overlap.FilterType = Enum.RaycastFilterType.Include
    Overlap.FilterDescendantsInstances = CharacterLoader.AllCharacters

    return workspace:GetPartBoundsInRadius(Character.HumanoidRootPart.Position, 500, Overlap)
end

local function IsLooking(Head, Character)
    local IsLooking = workspace:Raycast(Character.Head.Position, Head.Position - Character.Head.Position, Params)

    if IsLooking and IsLooking.Instance == Head then
        print("Returned true")
        return true
    else
        print("Returned false")
        return false
    end
end

local function Chatted(Package, Client)
    if not Client.Character then return end

    local ClientCharacter = Client.Character
    local Area = ObserveArea(ClientCharacter)

    Package.Message = Filter(Package.Message, Client)
    Params.FilterDescendantsInstances = {ClientCharacter}

    for _,Head in Area do
        
        local Character = Head.Parent
        local Player = Players:GetPlayerFromCharacter(Character)
        local AppearInWindow = true

        if Player ~= Client then AppearInWindow = IsLooking(Head, ClientCharacter) end

       Network.Chatted:fireClient(Player, {Sender = Client, Message = Package.Message, Type = "Normal", Windowed = AppearInWindow})
    end
end

Network.Chatted:onClient(Chatted)

return ChatService