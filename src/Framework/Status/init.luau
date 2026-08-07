local Status = {}
local StatusLibrary = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Statuses = script.Statuses

function Status.Start()
    for _,Module in Statuses:GetChildren() do
        local ModName = Module.Name
        StatusLibrary[ModName] = require(Module)
    end
    print("Status Library Loaded",  StatusLibrary)
end

function Status.Process()

end


ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
    print("processed", StatusName)
    if not StatusLibrary[StatusName] then return warn("Status going by "..StatusName.." not found.") end
end)

return Status