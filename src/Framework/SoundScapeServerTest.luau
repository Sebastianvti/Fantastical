Test = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundScape = require(ReplicatedStorage.Shared.SoundScape)


ReplicatedStorage.SSEvent.OnServerEvent:Connect(function(Player, Id)
    print("?")
    SoundScape.New(Id)
end)

return Test