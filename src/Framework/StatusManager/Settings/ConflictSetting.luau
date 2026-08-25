return 
    function(Package)

        local ConflictMain = require(script.Parent.Parent.Conflict)

        if not next(Package.CharacterSheet.Active_Timers) == nil or #Package.CharacterSheet.Active > 0 then 

        local ConflictCheck = ConflictMain.Begin(Package)

            return {Result = ConflictCheck}
        end
    
    return {Result = true}
end