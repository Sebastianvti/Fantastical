return function(Package)

    if table.find(Package.CharacterSheet.Active, Package.Status.Name) then return {Result = true} end

    local Main = require(script.Parent.Parent.Parent)
    local Utility = require(script.Parent.Parent.Parent.Utility)

-- Reform?
    if #Package.CharacterSheet.Active > 0 then 
        for _,Status in pairs(Package.CharacterSheet.Active) do
            if table.find(Main.GetIncompats(Status), Package.Status.Name) or table.find(Main.GetIncompatGroups(Status), Main.GetGroup(Package.Status.Name)) then
                if table.find(Main.GetWhitelist(Status), Package.Status.Name) then continue end
                
                if Package.Status.Settings.Dominant and Main.ComparePriority(Package.Status.Name, Status) then
                    print("Dominant status found, removing conflicting status "..Status.." and applying "..Package.Status.Name)

                    Main.ClearAll(Package.Player, Status)

                else

                return {Result = false, ErrorMsg = "Conflict found between "..Package.Status.Name.." and "..Status}
                end
            end
        end
    end
    return {Result = true}
end