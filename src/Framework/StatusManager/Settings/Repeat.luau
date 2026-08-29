return function(Package) -- theres no real reason to use this setting besides checking the timer again, id be surprised if i come back to this
    if #Package.RepeatSetting == 0 then return {Result = true} end

    local SettingMain = require(script.Parent)

    for _,Setting in Package.RepeatSetting do

        local SettingIndex = table.find(SettingMain.SettingKeys, Setting)
        local SettingKey = SettingMain.SettingKeys[SettingIndex]
        local Method = require(script.Parent[SettingKey])(Package)
        
        if not Method.Result then 
        return {Result = Method.Result, ErrorMsg = Method.ErrorMsg}
        end
    end
    return {Result = true}
end 