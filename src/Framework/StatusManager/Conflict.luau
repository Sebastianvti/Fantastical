local Conflict = {}
local Main = require(script.Parent)

local function MergeTables(Package) -- Compiles all active statuses together, timers which are inert are not counted.
    local Merge = {}  
    for _,Value in Package.CharacterSheet.Active do table.insert(Merge, Value)  end

    for Key,_ in Package.CharacterSheet.Active_Timers do 
        if Key.Reactive then table.insert(Merge, Key)  end 
    end

    return Merge
end

local function ComparePriority(Package, NewStatus)
    if Package.Status.Priority <= NewStatus.Status.Priority then 
    end
end

local function IsWhitelisted(Package, NewStatus)
    if table.find(NewStatus.Status.Whitelist, Package.Name) then return true end
    return false
end

local function IncompatGroups(Package, NewStatus)
    if table.find(NewStatus.Status.IncompatibleGroups, Package.Status.Group) then return false end
    return true
end

local function IncompatIndividual(Package, NewStatus)
        if table.find(NewStatus.Status.Incompatible, Package.Status.Group) then

            return false 
        end

    return true
end

function Conflict.Begin(Package)
    print("Conflict check.")
    local Actives = MergeTables(Package)
    if #Actives == 0 then return true end

    for _,Status in Actives do  -- Checking if incoming status is compatible with anything active.
        local NewStatus = Main.GetStatus(Status)
        if IsWhitelisted then return true end
        IncompatGroups()
        IncompatIndividual()
    end

end

return Conflict