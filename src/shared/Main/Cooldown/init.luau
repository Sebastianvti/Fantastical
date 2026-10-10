local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Data = script.Data

local ToolService = Shared.Main.ToolService
local Components = ToolService.Components
local LocalPlayer = Players.LocalPlayer

local Network = require(Shared.Network)
local InputTypes = require(Data.InputTypes)
local Cooldowns = require(Data.Cooldowns)

local CooldownManager = {}
CooldownManager.__index = CooldownManager


function CooldownManager.Start()
    for _,Component in Components:GetChildren() do
        local NewComponent = require(Component).New(nil, {})
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

function CooldownManager.New(Data, Preload)
    local self = setmetatable({}, CooldownManager)
    
    self.Character = LocalPlayer.Character
    self.Name = Data.ToolData.Name
    self.ComponentName = Data.ComponentName
    self.Component = Data.ComponentData
    self.BaseCooldown = Data.ComponentData.Cooldown
    self.CooldownProfile = Cooldowns[self.Character]
    
    return self
end

function CooldownManager:Init(Component)
    if not self.Character then return end

    self.InputType = Component.InputType
    self.CooldownMults = Component.CooldownMults
    
    self.CooldownProfile = Cooldowns[self.Character]
    self.InputCooldown = self.CooldownProfile[self.InputType]
    
    self.Stats = Network.Stats:get(LocalPlayer.UserId)
    return self:Calculate()
end

function CooldownManager:Multiply()
    self.ModifiedCooldown = self.BaseCooldown

    for _,Mult in self.CooldownMults do
        self.ModifiedCooldown = self.BaseCooldown * self.Stats.Modifiers[Mult]
    end
    return self.ModifiedCooldown
end

function CooldownManager:Pass()
    self.InputCooldown["Cooldown"] = self:Multiply()
    self.InputCooldown["LastUsed"] = os.clock()

    Network.ChangeCooldown:fireServer({Tool = self.Name, Component = self.ComponentName, Cooldown = self.InputCooldown["Cooldown"], Mults = self.CooldownMults})
end

function CooldownManager:Calculate()
    if not self.InputCooldown then warn("Invalid input type") return end
    if not self.InputCooldown["LastUsed"] then self:Pass() return true end
    
    if os.clock() - self.InputCooldown["LastUsed"] > self.InputCooldown["Cooldown"] then self:Pass() return true end
    return false
end

return CooldownManager