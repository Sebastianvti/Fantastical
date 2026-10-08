-- Used to verify cooldowns, client sends the tool they used and the cooldown they recieved.
-- A malicious client is unable to see the base cooldowns of other tools.
-- This will calculate their tools basecooldown * {multipliers}
-- This system will make no attempt at correcting the client, it is only there to act as warning
-- This system is forgiving, latency can cause a cooldown mismatch, but this is rare
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Framework = ServerScriptService.Framework
local Core = Framework.Core
local Services = Framework.Services
local StoreHouse = ServerStorage.StoreHouse
local Shared = ReplicatedStorage.Shared
local Main = Shared.Main

local Tools = StoreHouse.Tools
local ToolService = Main.ToolService
local Components = ToolService.Components

local EquipmentService = require(Services.EquipmentService)
local Network = require(Shared.Network)
local CharacterSheet = require(Core.CharacterLoader.Template)

local CooldownServer = {}
local Characters = {}
local Suspicious = {}

function CooldownServer.Start(Sheet)
    Characters = Sheet

    -- for _,Component in Components:GetChildren() do
    --     local NewComponent = require(Component).New(nil, {})
    --     if not NewComponent.InputType then continue end

    --     CharacterSheet.InputTypes[NewComponent.InputType] = {}
    -- end
end

function CooldownServer.Multiply(Data)
    local ModifiedCooldown = 0

    for _,Mult in Data.Mults do
        ModifiedCooldown = Data.Config.Cooldown * Characters[Data.Character].Mult_Sheet[Mult]
    end

    if Data.Cooldown ~= ModifiedCooldown then return {Result = false, Mismatch = ModifiedCooldown} end
    return {Result = true}
end

function CooldownServer.Calculate(Package, Player)
    if not Player.Character then return end 

    Package.Character = Player.Character
    Package.Config = EquipmentService.GetTool(Package.Tool)
    if not Package.Config then return end

    Package.Config = Package.Config.Components[Package.Component]

    local Multiply = CooldownServer.Multiply(Package)
    if not Multiply.Result then
        warn(Player.Name.." has been detected with a mismatched cooldown")

        Package.Character = nil
        Package.Mismatch = Multiply.Mismatch
        Package.MismatchDifference = Package.Cooldown - Package.Mismatch
        
        if not Suspicious[Player] then Suspicious[Player] = {} end
        table.insert(Suspicious[Player], Package)
        if #Suspicious[Player] > 1 then warn(Player.Name.." has multiple mismatched cooldowns, this is either a bug, malicious or latency") print(Suspicious) end
    end
end

Network.ChangeCooldown:onServer(CooldownServer.Calculate)

return CooldownServer