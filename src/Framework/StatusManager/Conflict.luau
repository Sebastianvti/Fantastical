local Conflict = {}

local function MergeTables(Package)
    local Merge = {}
    for _,Value in Package.CharacterSheet.Active do Merge[Value]
    for Key,_ in Package.CharacterSheet.Active_Timers do Merge[Key]
    return Merge
end

function Conflict.Begin(Package)
    local Actives = MergeTables(Package)
    print("conflict check began")
end

return Conflict