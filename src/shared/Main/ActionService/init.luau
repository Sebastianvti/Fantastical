local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ActionFolder = script.Actions
local Data = script.Data

local InputTrack = require(Data.InputTrack)
local Network = require(Shared.Network)

local Threads = {}
local Actions = {}
local ActionService = {}
ActionService.__index = ActionService

function ActionService.Start()
    for _,Module in ActionFolder:GetChildren() do
        local NewModule = require(Module)
        Actions[Module.Name] = NewModule
    end
end

function ActionService.New(Action : string, Time : number) -- we will see if this stands the test of time
    if not Action or not Actions[Action] then warn("Action could not be found.") return end
    local self = setmetatable({}, ActionService)

    self.ActionGroup = Actions[Action].Group
    self.Action = Action
    self.Time = Time

    if InputTrack[self.ActionGroup] == "" then return self:Update() end
    return false
end

function ActionService:Update()
    InputTrack[self.ActionGroup] = self.Action

    Threads[HttpService:GenerateGUID(false)] = task.delay(self.Time, function()
        InputTrack[self.ActionGroup] = ""
    end)
    
    Network.ChangeAction:fireServer({Action = self.Action, Time = os.clock()})
    return true
end

return ActionService