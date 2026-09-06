local ChatService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local CharacterLoader = require(script.Parent.CharacterLoader)

local Overlap = OverlapParams.new()


local function ObserveArea(Character : Model)
    Overlap.FilterType = Enum.RaycastFilterType.Include
    Overlap.FilterDescendantsInstances = CharacterLoader.AllCharacters

    return workspace:GetPartBoundsInRadius(Character.HumanoidRootPart.Position, 500, Overlap)
end

local function Chatted(Player, Msg)
    local Area = ObserveArea(Player.Character)
    for _,Head in Area do
        
        local Character = Head.Parent
        local Player = Players:GetPlayerFromCharacter(Character)

        Network.Chatted:FireClient(Player, Msg)
    end
end

Network.Chatted.OnServerEvent:Connect(Chatted)

return ChatService