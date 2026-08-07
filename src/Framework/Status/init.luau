local Status = {}
Status.__index = Status

local StatusLibrary = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Statuses = script.Statuses

function Status.Start()
    for _,Module in Statuses:GetChildren() do
        local ModName = Module.Name
        print(require(Module))
        StatusLibrary[ModName] = require(Module)
    end
    print("Status Library Loaded",  StatusLibrary)
end

function Status.New(Player, Status)
    local self = setmetatable({}, Status)

    
    return self
end

ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
    print("processed", StatusName)
    if not StatusLibrary[StatusName] then return warn("Status going by "..StatusName.." not found.") end
    Status.New(Player, StatusLibrary[StatusName])
end)

return Status