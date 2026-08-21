local Settings = {}
local SettingKeys = {
    -- top is first, and bottom is last. settings at the top usually modify base behavior
    -- At the bottom should always be finalizer
    CanStack = require(script.CanStack),
    TimerSetting = require(script.TimerSetting),
    VerifyConflict = require(script.Conflicts.VerifyConflict)
    Conflicts = require(script.Parent.Conflicts)
    Finalizer = require(script.Parent.Finalizer)
}

function Settings.VerifySettings(Package)
    for Setting,Method in SettingKeys do
        if Package.Settings[Setting] == true or Package.Settings[Setting] == nil then
            
            local SettingResult = Method(Package)
            if not SettingResult.Result then warn(SettingResult.ErrorMsg) return end
        end
    end 
    return true
end


return Settings