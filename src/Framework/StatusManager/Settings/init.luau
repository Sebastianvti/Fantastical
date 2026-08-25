local Settings = {}
local SettingKeys = {
    -- top is first, and bottom is last. settings at the top usually modify base behavior
    -- At the bottom should always be finalizer
    CanStack = require(script.CanStack),
    TimerSetting = require(script.TimerSetting),
    ConflictSetting = require(script.ConflictSetting)
}

function Settings.VerifySettings(Package)
    if table.find(Package.SettingBlacklist, "All") then return true end
    for Setting,Method in SettingKeys do
        if Package.Settings[Setting] == true or Package.Settings[Setting] == nil and not table.find(Package.SettingBlacklist, Setting) then
            
            local SettingResult = Method(Package)
            if not SettingResult.Result then warn(SettingResult.ErrorMsg) return false end
        end
    end 
    return true
end


return Settings