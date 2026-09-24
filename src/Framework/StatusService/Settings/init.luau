local Settings = {}

Settings.SettingKeys = {
    -- top is first, and bottom is last. settings at the top usually modify base behavior
    -- At the bottom should always be finalizer
    "CanStack",
    "Staggered",
    "TimerSetting",
    "ConflictSetting",
    "Repeat" -- useful if you need to check through a setting twice, for example reactive timers need to pass through all checks then return back to timer, repeating the timersetting
}

function Settings.VerifySettings(Package)
    if table.find(Package.SettingBlacklist, "All") then return true end
    for _,Method in Settings.SettingKeys do
        if Package.Settings[Method] == true or Package.Settings[Method] == nil then -- if setting exists on status and is true then it will check the setting, if it doesnt exist but is displayed then check
            if table.find(Package.SettingBlacklist, Method) then continue end
            
            local SettingResult = require(script[Method])(Package)
            if not SettingResult.Result then warn(SettingResult.ErrorMsg) return false end
        end
    end 
    return true
end


return Settings