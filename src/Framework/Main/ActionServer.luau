-- Used to verify actions, this system trusts the user and will not make any attempts to correct the client
-- but it will report if a client is signficantly far behind or ahead their intended action
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main

local ActionService = Main.ActionService
local ActionFolder = ActionService.Actions

local Network = require(Shared.Network)

local Actions = {}
local ActionServer = {}

function ActionServer.Start()
    for _,Module in ActionFolder:GetChildren() do
            local NewModule = require(Module)
            Actions[Module.Name] = NewModule
    end
end

function ActionServer.CharacterLoaded(Character)

end

function ActionServer.New(Package, Player)
    local NewTrack = {}
    Package.Time = os.clock() - Package.Time
end

function ActionServer.Time()
    
end

Network.ChangeAction:onServer(ActionServer.New)

return ActionServer