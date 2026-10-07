local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main

local ActionService = Main.ActionService

local Network = require(Shared.Network)

local CooldownServer = {}

function CooldownServer.CharacterLoaded(Character)

end

function CooldownServer.New(Package)
    Package.Time = os.clock - Package.Time
end

function CooldownServer.Time()
    
end

-- Network.ChangeAction:onServer(CooldownServer.New)

return CooldownServer