return 
    function(Package)
        local ConflictMain = require(script.Parent.Parent.Conflict)
        if next(Package.CharacterSheet.Active_Timers) or #Package.CharacterSheet.Active > 0 then 

        local ConflictCheck = ConflictMain.Begin(Package)

            return {Result = ConflictCheck, ErrorMsg = "Conflict detected, and failed to pass"}
        end
    
    return {Result = true}
end