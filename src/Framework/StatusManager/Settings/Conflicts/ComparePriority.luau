return function(StatusName : string, OtherStatusName : string)

    local Main = require(script.Parent.Parent.Parent)
    local StatusData = Main.GetSettings(StatusName)
    local OtherStatusData = Main.GetSettings(OtherStatusName)

    if not StatusData or not OtherStatusData then return warn("One or both statuses not found.") end

    if StatusData.Priority < OtherStatusData.Priority then
        return true
    else
        return false
    end
end