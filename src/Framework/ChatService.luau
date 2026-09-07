local ChatService = {}

local Players = game:GetService("Players")
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

local function Chatted(Sender, Msg)
    print(Sender, Msg)
    local Character = Sender.Character
    local Area = ObserveArea(Character)

    Params.FilterDescendantsInstances = {Character}

    for _,Head in Area do
        
        local Character = Head.Parent
        local Player = Players:GetPlayerFromCharacter(Character)

        if Player ~= Sender then workspace:Raycast(Character.Head, Head.Position - Character.Head.Position) end

       --Network.Chatted:FireClient(Player, Msg)
    end
end

--Network.Chatted:onServer(Chatted)

return ChatService