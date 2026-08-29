local ProximityPromptService = game:GetService("ProximityPromptService")
return function(Package)
    local Main = require(script.Parent.Parent)
    local TimerMain = require(script.Parent.Parent.Timer)
    local Array = {}

    for Index,Value in Package.Base do 
        if Package.Settings[Value.."Timer"] then table.insert(Array, Index) end
    end

    if Package.Settings.ReactiveTimer and not table.find(Package.RepeatSetting, "TimerSetting") or Package.Settings.RemoveOnAddTimer and not table.find(Package.RepeatSetting, "TimerSetting")  then 
        table.insert(Package.RepeatSetting, "TimerSetting") 
        return {Result = true} 
    end

    if Package.Settings.RemoveOnAddTimer and #Array == 0 then 
        TimerMain.RemoveOnAddSetting(Package, {}, 0 , true)
        return {Result = true}
    end

    if #Array == 0 and not table.find(Package.RepeatSetting, "TimerSetting") then return {Result = true} end
    

    if #Array > 0 and Array[1] > 1 then 
        local Value = Array[1]
        local NewPackage = Package table.clear(NewPackage.Base)

        for i = 1, math.abs(1 - Value) - 1 do
            table.insert(NewPackage.Base, Package.Base[i])
        end

        Main.Batch(NewPackage)
    end

    TimerMain.Begin(Package, Array)
    return {Result = false, ErrorMsg = "Timer detected. Status is being applied through the timer."}

end