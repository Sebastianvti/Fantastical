return function(Package)
    if #Package.RepeatSetting == 0 then return {Result = true} end

    local SettingMain = require(script.Parent)

    for _,Setting in Package.RepeatSetting do
        SettingMain.SettingKeys[Setting](Package)
    end
    return {Result = true} 
end 