local Settings = {}

Settings.SettingKeys = {
    -- top is first, and bottom is last. settings at the top usually modify base behavior
    -- At the bottom should always be finalizer
    CanStack = require(script.CanStack),
   -- StaggeredSetting = require(script.StaggerSetting),
    TimerSetting = require(script.TimerSetting),
    ConflictSetting = require(script.ConflictSetting),
    Repeat = require(script.Repeat)
}

function Settings.VerifySettings(Package)
    if table.find(Package.SettingBlacklist, "All") then return true end
    for Setting,Method in Settings.SettingKeys do
        if Package.Settings[Setting] == true or Package.Settings[Setting] == nil and not table.find(Package.SettingBlacklist, Setting) then
            
            local SettingResult = Method(Package)
            if not SettingResult.Result then warn(SettingResult.ErrorMsg) return false end
        end
    end 
    return true
end


return Settings