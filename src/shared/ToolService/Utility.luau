local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local LocalPlayer = Players.LocalPlayer

local Animations = require(Shared.Animation)
local Cooldown = require(Shared.Cooldown)
local Utility = {}

function Utility.Preload(ToolData)
    local Preload = {}
    for Key,_ in ToolData do
        if not Utility[Key] then continue end
        Utility[Key](ToolData, Preload)
    end

    return Preload
end

function Utility.Animations(ToolData, Preload)
    Preload["Animations"] = Animations.LoadAnimations(LocalPlayer, ToolData.Animations)
end

function Utility.Cooldown(ToolData, Preload)
    Preload["Cooldown"] = Cooldown.New(ToolData)
end

return Utility