local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Data = script.Data

local InputTrack = require(Data.InputTrack)
local Network = require(Shared.Network)
local ActionService = {}
ActionService.__index = ActionService

local function AddToInputTrack(InputType : string)

end

function ActionService.New(Component) -- we will see if this stands the test of time
    local self = setmetatable({}, ActionService)

    self.InputType = Component.InputType
    self.Cooldown = Component.Time

    return self
end

function ActionService:Update()

    -- steps
    -- set time on client
    -- send info to server
    -- server do math
    -- return with true time
    
end

return ActionService