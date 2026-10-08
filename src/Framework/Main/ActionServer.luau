local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.Shared
local Framework = ServerScriptService.Framework

local Core = Framework.Core
local Main = Shared.Main

local ActionService = Main.ActionService
local ActionFolder = ActionService.Actions

local ActionTrack  = require(ActionService.Data.InputTrack)
local Network = require(Shared.Network)
local CharacterSheet = require(Core.CharacterLoader.Template)

local CharacterSheets = {}
local Threads = {}
local Actions = {}
local ActionServer = {}
ActionServer.__index = ActionServer

function ActionServer.Start(Sheet)
    CharacterSheet.ActionTrack = ActionTrack
    CharacterSheets = Sheet

    for _,Module in ActionFolder:GetChildren() do
        local NewModule = require(Module)
        Actions[Module.Name] = NewModule
    end
end

-- OOP WAS NOT NECESSARY but then again i just copy pasted from client
-- basically this has 0 security if the client is malicious, i dont really see it necessary, since it would be overt if someone was manipulating it
-- although this script exists if its really needed
function ActionServer.New(Package, Player) -- we will see if this stands the test of time
    if not Player.Character then return end
    local self = setmetatable({}, ActionServer)

    self.Character = Player.Character
    self.ActionGroup = Actions[Package.Action].Group
    self.Action = Package.Action
    self.Sheet = CharacterSheets[self.Character]

    self:Update()
end

function ActionServer:Update()
    self.Sheet.ActionTrack[self.ActionGroup] = self.Action
    print(CharacterSheets)
end

Network.ChangeAction:onServer(ActionServer.New)

return ActionServer