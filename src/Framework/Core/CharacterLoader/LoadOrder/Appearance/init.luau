local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local Directory = Workspace.Directory
local StoreHouse = ServerStorage.StoreHouse
local Shared = ReplicatedStorage.Shared

local InvisHead, HeadsFolder = StoreHouse.Cache.Head, Directory.Heads

local Cache = require(Shared.Misc.Cache)
local Template = require(script.Template)

local HeadCache,WeldCache,DecalCache = Cache.New(InvisHead, 150, true), Cache.New("WeldConstraint", 150, true), Cache.New("Decal", 1050 + 100, true) --1050 decals for a 150 server + surplus
local Appearance = {}

function Appearance.CharacterInit(Character : Model)
    local NewHead : Part = HeadCache:GetInstance()
    local WeldConstraint : WeldConstraint = WeldCache:GetInstance()

    NewHead.Name = Character.Name
    NewHead.Size = Character.Head.Size
    NewHead.Parent = HeadsFolder
    NewHead.Position = Character.Head.Position

    WeldConstraint.Part0 = Character.Head
    WeldConstraint.Part1 = NewHead
    WeldConstraint.Parent = Character.Head

    for Key,Value in Template do
        local NewDecal : Decal = DecalCache:GetInstance()
        NewDecal.Name = Key
        NewDecal.ZIndex = Value.ZIndex
        NewDecal.Parent = NewHead
    end
end

return Appearance