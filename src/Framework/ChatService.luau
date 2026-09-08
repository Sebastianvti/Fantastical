local ChatService = {}

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local CharacterLoader = require(script.Parent.CharacterLoader)

local Overlap = OverlapParams.new()
local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude

local function ObserveArea(Character : Model)
    Overlap.FilterType = Enum.RaycastFilterType.Include
    Overlap.FilterDescendantsInstances = CharacterLoader.AllCharacters

    return workspace:GetPartBoundsInRadius(Character.HumanoidRootPart.Position, 500, Overlap)
end

local function IsLooking(Head, Character)
    print(Head, Character)
    local IsLooking = workspace:Raycast(Character.Head.Position, Head.Position - Character.Head.Position, Params)
    local IsLooking2 = workspace:Raycast(Character.Head.Position, workspace.Dummy.Head.Position - Character.Head.Position, Params)

    print(IsLooking)
    print(IsLooking2)

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