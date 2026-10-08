local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main
local LocalPlayer = Players.LocalPlayer

local Animations = require(Shared.Animation)
local Cooldown = require(Main.Cooldown)
local Utility = {}

function Utility.Preload(Data)
    local Preload = {
        Main = Data.ToolData.Name,
        Name = Data.ComponentName
    }

    for Key,_ in Data.ComponentData do
        if not Utility[Key] then continue end
        Utility[Key](Preload, Data)
    end

    return Preload
end

function Utility.Animations(Preload, Data)
    Preload["Animations"] = Animations.LoadAnimations(LocalPlayer, Data.ComponentData.Animations)
end

function Utility.Cooldown(Preload, Data)
    Preload["Cooldown"] = Cooldown.New(Data, Preload)
end

return Utility