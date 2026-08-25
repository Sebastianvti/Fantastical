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
    local TopPriority 
    if Package.Status.Priority <= NewStatus.Status.Priority then 
        TopPriority = Package
    else
        TopPriority = NewStatus
    end

    return TopPriority
end

local function RemovePackage(RemovePackage, KeepPackage)
    Main.ClearAll(RemovePackage.Name)


    return KeepPackage
end

local function Dominance(Package, NewStatus)

    local PackageDomin = Package.Settings.Dominant
    local NewStatusDomin = NewStatus.Settings.Dominant 

    local DominanceResult = {
        [1] = RemovePackage(Package, NewStatus)
        [2] = RemovePackage(NewStatus, Package)
        [3] = ComparePriority(Package, NewStatus)
    }

    if not PackageDomin and not NewStatusDomin then return true end
    
    local PackDominNum = (PackageDomin and 1 ) or 0
    local NewStatNum = (PackageDomin and 2 ) or 0
    local PackageResult = PackDominNum + NewStatNum

    
    return DominanceResult[PackageResult] or true
end

local function IsWhitelisted(Package, NewStatus)
    if table.find(NewStatus.Status.Whitelist, Package.Name) then return true end
    return false
end

local function IncompatGroups(Package, NewStatus)
    if table.find(Package.Status.IncompatibleGroups, NewStatus.Status.Group) or table.find(NewStatus.Status.IncompatibleGroups, Package.Status.Group)  then 

    end
    return true
end

local function IncompatIndividual(Package, NewStatus, CompatType)
        if table.find(Package.Status.Incompatible, NewStatus.Name) or table.find(NewStatus.Status.Incompatible, Package.Name) then

            local DominanceCheck = Dominance(Package, NewStatus)
            

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