return 
    function(Package)

        local ConflictMain = require(script.Parent.Parent.Conflict)

        if next(Package.CharacterSheet.Active_Timers) == nil or #Package.CharacterSheet.Active == 0 then 
           if not ConflictMain.Begin(Package) return false end
        end
    
    return {Result = true}
end