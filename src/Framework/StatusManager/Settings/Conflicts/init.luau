return 
    function(Package)

      local DominantSetting = Package.Status.Settings.Dominant
      local Main = require(script.Parent.Parent)
      local Utility = require(script.Parent.Parent.Utility)
      
    if table.find(Package.CharacterSheet.Active, Package.Status.Name) then return {Result = true} end

       if #Package.Status.Incompatible == 0 and #Package.Status.IncompatibleGroups == 0 then print("No conflicts found, you should disable this setting if it wont be used.") return true end

        for _, Status : string in pairs(Package.CharacterSheet.Active) do
            if not table.find(Package.Status.Incompatible, Status) or not table.find(Package.Status.IncompatibleGroups, Main.GetGroup(Status)) or table.find(Package.Status.Whitelist, Status) then continue end
  
            if DominantSetting and Main.ComparePriority(Package.Status.Name, Status) then
                print("Dominant status found, removing conflicting status "..Status.." and applying "..Package.Status.Name)
                
                local _ = Package.Status.Custom.Conflict and Package.Status.Custom.Conflict()
                
                Main.ClearAll(Package.Player, Status)

            else
                return {Result = false, ErrorMsg = "Conflict was found."}
        end
    end
    return {Result = true}
end