local Utility = {}
Utility.__index = Utility

local HttpService = game:GetService("HttpService")

local Math = {
    Add = function(a, b) return a + b end,
    Subtract = function(a, b) return a - b end,
}

local TableOperators = {
    Add = function(Table, Key) table.insert(Table, Key) return Table end,
    Subtract = function(Table, Key) table.remove(Table, table.find(Table, Key)) return Table end
}

local function StaggeredThread(Package)
    local Index = 0
    while task.wait(Package.Settings.StaggerDuration) do
        if Index == Package.Settings.StaggerAmount then break end
        Index += 1
    end
end

local function Process(self, Operator : string)
    for Key, Value in pairs(self.Status.Sheet) do
        if not self.CharacterSheet.Sheet[Key] then continue end

        self.CharacterSheet.Sheet[Key] = Math[Operator](self.CharacterSheet.Sheet[Key], Value)
    end
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

    local Sheet = self.CharacterSheet
    local Status = self.Status

    local _ = Status.Custom[self.Base[Index]] and Status.Custom[self.Base[Index]](self)
        
    Sheet.Active = TableOperators[self.Base[Index]](Sheet.Active, Status.Name)

    return self
end

function Utility.CanStack(self, Index)
    local self = Utility.Modify(self, Index)

    local Sheet = self.CharacterSheet
    local Status = self.Status

    local Stack = Sheet.Active_Stacks
    local StackKey = (Status.Name.."_Stack")

    Stack[StackKey] = TableOperators[self.Base[Index]](Stack[StackKey], Status.Name)

    return self
end

return Utility