local Status = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
    print("processed", StatusName)
    if not Status[StatusName] then return warn("Status going by "..StatusName.." not found.") end
end)

return Status