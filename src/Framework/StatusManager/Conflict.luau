local Conflict = {}
local Main = require(script.Parent)

-- Basically, this might be a bit confusing so heres a summary.
-- This system is pretty self explainatory, but when it comes to deciding of whether to pass, remove or fail certain statuses its a bit silly.
-- If the status is the one being currently processed, then we return false if it fails and true if it passes.
-- If we are referencing an active status, then we have to reference the name or package of it, and not the boolean. because it has to be removed by the system

local function MergeTables(Package) -- Compiles all active statuses together, timers which are inert are not counted.
    local Merge = {}  
    for _,Value in Package.CharacterSheet.Active do table.insert(Merge, Value)  end

    for Key,_ in Package.CharacterSheet.Active_Timers do 
        if Key.Reactive then table.insert(Merge, Key)  end 
    end

    return Merge
end

local function RemovePackage(RemovePackage, KeepPackage)
    local Player = RemovePackage.Player or KeepPackage.Player
    Main.ClearAll(Player.Character, RemovePackage.Name)

    return true
end

local function ComparePriority(Package, NewStatus)
    local TopPriority 
    if Package.Status.Priority == NewStatus.Priority then TopPriority = NewStatus return TopPriority end -- If priority is equal then the one that is currently added wins.

    if Package.Status.Priority < NewStatus.Priority then 
        TopPriority = true
        RemovePackage(NewStatus, Package)
    else
        TopPriority = false
    end

    return TopPriority
end

local function FailPackage() -- just returns false
    return false
end

local function Dominance(Package, NewStatus)
    local PackageDomin = Package.Settings.Dominant
    local NewStatusDomin = NewStatus.Dominant 

    local DominanceResult = {
        [1] = FailPackage,
        [2] = RemovePackage,
        [3] = ComparePriority,
    }

    if not PackageDomin and not NewStatusDomin then return true end
    
    local PackDominNum = (PackageDomin and 1 ) or 0
    local NewStatNum = (PackageDomin and 2 ) or 0
    local PackageResult = PackDominNum + NewStatNum

    return DominanceResult[PackageResult](Package, NewStatus)
end

local function IsWhitelisted(Package, NewStatus)
    if table.find(NewStatus.Whitelist, Package.Name) then return true end
    return false
end

local function IncompatGroups(Package, NewStatus)
    if not table.find(Package.Status.IncompatibleGroups, NewStatus.Group) and not table.find(NewStatus.IncompatibleGroups, Package.Group)  then return true end
    local DominanceCheck = Dominance(Package, NewStatus)
            
    return DominanceCheck
end

local function IncompatSingle(Package, NewStatus)
    if not table.find(Package.Status.Incompatible, NewStatus.Name) and not table.find(NewStatus.Incompatible, Package.Name) then return true end
    local DominanceCheck = Dominance(Package, NewStatus)

    return DominanceCheck
end

function Conflict.Begin(Package)

    local Actives = MergeTables(Package)
    if #Actives == 0 then return true end 

    for _,Status in Actives do  -- Checking if incoming status is compatible with anything active.
        local NewStatus = Main.GetStatus(Status)
        if IsWhitelisted(Package, NewStatus) then return true end
        if not IncompatGroups(Package, NewStatus) or not IncompatSingle(Package, NewStatus) then print("Returned flase") return false end
    end
    return true 
end

return Conflict