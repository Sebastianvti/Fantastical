local Settings = {}
local SettingKeys = {
    -- top first, bottom last | if not specified then order is irrelevant to the setting
    -- DontPass is used for settings which are a dependency of other settings but not used by the main setting check, dunno if its necessary
    CanStack = require(script.CanStack),
    TimerSetting = require(script.TimerSetting),
    VerifyConflict = require(script.Conflicts.VerifyConflict)
}

for _,Module in script:GetDescendants() do
    local ModName = Module.Name
    if not SettingKeys[ModName] then
    SettingKeys[ModName] = require(Module)
    end
end

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