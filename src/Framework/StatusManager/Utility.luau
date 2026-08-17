local Utility = {}
Utility.__index = Utility

local Math = {
    Add = function(a, b) return a + b end,
    Subtract = function(a, b) return a - b end,
}

local TableOperators = {
    Add = function(Table, Key) table.insert(Table, Key) return Table end,
    Subtract = function(Table, Key) table.remove(Table, table.find(Table, Key)) return Table end
}

local function Process(self, Operator : string)
    for Key, Value in pairs(self.Status.Sheet) do
        if not self.CharacterSheet.Sheet[Key] then continue end

        self.CharacterSheet.Sheet[Key] = Math[Operator](self.CharacterSheet.Sheet[Key], Value)
    end
end

function Utility.Modify(self)
    self = setmetatable(self,  Utility)

    local Sheet = self.CharacterSheet
    local Status = self.Status

    for _,Value in self.Base do
        local _ = Status.Custom[Value] and Status.Custom[Value](self)
        
        Process(self, Value)
        Sheet.Active = TableOperators[Value](Sheet.Active, Status.Name)
    end
    print(Sheet)
    return self
end

function Utility.CanStack(self)
    local self = Utility.Modify(self)

    local Sheet = self.CharacterSheet
    local Status = self.Status

    local Stack = Sheet.Active_Stacks
    local StackKey = (Status.Name.."_Stack")

    for _,Value in self.Base do
    Stack[StackKey] = TableOperators[Value](Stack[StackKey], Status.Name)
    end

    return self
end

return Utility