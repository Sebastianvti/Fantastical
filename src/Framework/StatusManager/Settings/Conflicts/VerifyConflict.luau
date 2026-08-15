return function(Package)

    if table.find(Package.CharacterSheet.Active, Package.Status.Name) then return true end

    local Main = require(script.Parent.Parent.Parent)
    local Priority = require(script.Parent.ComparePriority)
    local Utility = require(script.Parent.Parent.Parent.Utility)

if #Package.CharacterSheet.Active > 0 then 
    for _,Status in pairs(Package.CharacterSheet.Active) do
        if table.find(Main.GetIncompats(Status), Package.Status.Name) or table.find(Main.GetIncompatGroups(Status), Main.GetGroup(Package.Status.Name)) then
            if table.find(Main.GetWhitelist(Status), Package.Status.Name) then continue end
            
            if Package.Status.Settings.Dominant and Priority(Package.Status.Name, Status) then
                print("Dominant status found, removing conflicting status "..Status.." and applying "..Package.Status.Name)

                Main.ClearAll(Package.Player, Status)

            else

            print("Conflict found between "..Package.Status.Name.." and "..Status)
            return false
            end
        end
    end
end
    return true
end