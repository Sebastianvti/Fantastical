-- Used to verify cooldowns, client sends the tool they used and the cooldown they recieved.
-- A malicious client is unable to see the base cooldowns of other tools.
-- This will calculate their tools basecooldown * {multipliers}
-- This system will make no attempt at correcting the client, it is only there to act as warning
-- This system is forgiving, latency can cause a cooldown mismatch, but this is rare
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local StoreHouse = ServerStorage.StoreHouse
local Shared = ReplicatedStorage.Shared
local Main = Shared.Main

local Tools = StoreHouse.Tools
local ToolService = Main.ToolService
local Components = ToolService.Components

local Network = require(Shared.Network)

local CooldownServer = {}
local Suspicious = {}
local CooldownSheet = {}

function CooldownServer.Start(Sheet)
    CooldownSheet = Sheet

    for _,Component in Components:GetChildren() do
        local NewComponent = require(Component).New(nil, {})
        if not NewComponent.InputType then continue end

        CooldownSheet.InputTypes[NewComponent.InputType] = {}
    end
end

function CooldownServer.Multiply(Package, Referenced : number, Character)
    local ModifiedCooldown = 0
   for _,Mult in Package.Mults do
        local ModifiedCooldown = self.BaseCooldown * self.Stats.Modifiers[Mult]
    end

    if not Referenced ~= ModifiedCooldown then return false end
end

function CooldownServer.Calculate(Package, Player)
    if not Player.Character then return end

    local Tool = Tools:FindFirstChild(Package.Tool) 
    if not Tool then warn("Tool was not found") return end  

    local Config = require(Tool.Config)
    local Component = Config[Package.Component]
    local Cooldown = Component.Cooldown
    
    if not CooldownServer.Multiply(Package, Package.Cooldown, Player.Character) then
        warn(Player.Name.." has been detected with a mismatched cooldown")
        Suspicious[Player] = {}
    end
end

Network.ChangeCooldown:onServer(CooldownServer.Calculate)

return CooldownServer