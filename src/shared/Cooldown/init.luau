local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Data = script.Data

local ToolService = Shared.ToolService
local Components = ToolService.Components

local Network = require(Shared.Network)
local InputTypes = require(Data.InputTypes)
local Cooldowns = require(Data.Cooldowns)

local CooldownManager = {}
CooldownManager.__index = CooldownManager


function CooldownManager.Start()
    for _,Component in Components:GetChildren() do
        local NewComponent = require(Component).New()
        if not NewComponent.InputType then continue end

        InputTypes[NewComponent.InputType] = {}
    end
end

function CooldownManager.CharacterAdded(Character)
    Cooldowns[Character] = InputTypes
end


function CooldownManager.CharacterDied(Character)
    Cooldowns[Character] = nil
end

function CooldownManager.Begin(Component)
    local self = setmetatable({}, CooldownManager)

    self.InputType = Component.InputType
    self.Character = Component.Character
    self.CooldownMults = Component.CooldownMults
    self.BaseCooldown = Component.Cooldown
    
    self.CooldownProfile = Cooldowns[self.Character]
    self.InputCooldown = self.CooldownProfile[self.InputType]
    
    if self.Character then self.Stats = Network.Stats:get(Players:GetPlayerFromCharacter(self.Character)) end

    return self:Calculate()
end

function CooldownManager:Multiply()

end

function CooldownManager:Pass()
    self.InputCooldown["Cooldown"] = self:Multiply()
    self.InputCooldown["LastUsed"] = os.clock()
    
    print("launched")
end

function CooldownManager:Calculate()
    if not self.InputCooldown then warn("Invalid input type") return end

    if not self.InputCooldown["LastUsed"] then self:Pass() return true end

    if os.clock() - self.InputCooldown["LastUsed"] > self.InputCooldown["Cooldown"] then self:Pass() return true end
    return false
end

return CooldownManager