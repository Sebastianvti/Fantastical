return function(Package)
    if #Package.RepeatSetting == 0 then return {Result = true} end

    local SettingMain = require(script.Parent)

    for _,Setting in Package.RepeatSetting do

        local SettingIndex = table.find(SettingMain.SettingKeys, Setting)
        local SettingKey = SettingMain.SettingKeys[SettingIndex]
        local Method = require(script.Parent[SettingKey])
        Method(Package)
    end
    return {Result = false, ErrorMsg = "Setting within the repeat function failed or began its own process."}
end 