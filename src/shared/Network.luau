local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Network = require(Shared.QuickNet)
local Type = Network.Data

return {
    Chatted = Network:register("Chatted", Type.String)

}   