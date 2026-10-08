local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main



local Network = require(Shared.Network)

local CooldownServer = {}

function CooldownServer.CharacterLoaded(Character)

end

function CooldownServer.New(Package, Player)
    Package.Time = os.clock - Package.Time
end

function CooldownServer.Time()
    
end

Network.ChangeCooldown:onServer(CooldownServer.New)

return CooldownServer