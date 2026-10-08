local Utility = {}
Utility.__index = Utility

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local Math = {
    Add = function(a, b) return a + b end,
    Subtract = function(a, b) return a - b end,
}

local TableOperators = {
    Add = function(Table, Key) table.insert(Table, Key) return Table end,
    Subtract = function(Table, Key) table.remove(Table, table.find(Table, Key)) return Table end
}

local function StaggeredThread(Package) -- unfinished
    local Index = 0
    while task.wait(Package.Settings.StaggerDuration) do
        if Index == Package.Settings.StaggerAmount then break end
        Index += 1
    end
end

local function Process(self, Operator : string)
    local Changes = {}
    for Key, Value in pairs(self.Status.Mult_Sheet) do
        if not self.CharacterSheet.Mult_Sheet[Key] then continue end
        local Result = Math[Operator](self.CharacterSheet.Mult_Sheet[Key], Value)

        self.CharacterSheet.Mult_Sheet[Key] = Result
        Changes[Key] = Result
    end
    if next(Changes) == nil then print("..") return end

    local UserID = self.Player.UserId

    Network.Stats:audience(UserID, self.Player)
    Network.Stats:update(UserID, {Owner = UserID, Modifiers = Changes})
end

function Utility.Instant(self, Index)
    Process(self, self.Base[Index])
end

function Utility.Staggered(self)
    local ThreadId = HttpService:GenerateGUID()
    self.CharacterSheet.Stagger_Thread[ThreadId] = {}
    local ThreadKey = self.CharacterSheet.Stagger_Thread[ThreadId]
    
    ThreadKey.Task = task.spawn(StaggeredThread, self) -- put task inside a table
    ThreadKey.Name = self.Name
end

function Utility.Modify(self, Index)
    self = setmetatable(self,  Utility)

    local Mult_Sheet = self.CharacterSheet
    local Status = self.Status

    local _ = Status.Custom[self.Base[Index]] and Status.Custom[self.Base[Index]](self)
        
    Mult_Sheet.Active = TableOperators[self.Base[Index]](Mult_Sheet.Active, Status.Name)

    return self
end

function Utility.CanStack(self, Index)
    local self = Utility.Modify(self, Index)

    local Mult_Sheet = self.CharacterSheet
    local Status = self.Status

    local Stack = Mult_Sheet.Active_Stacks
    local StackKey = (Status.Name.."_Stack")

    Stack[StackKey] = TableOperators[self.Base[Index]](Stack[StackKey], Status.Name)

    return self
end

return Utility