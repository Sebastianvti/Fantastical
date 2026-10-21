local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local Utility = {}

local function Enable(Packet) -- move somewhere else later
    local Instance = Packet.Instance
    Instance.Enabled = not Instance.Enabled
end

Network.Enable:onServer(Enable)
return Utility