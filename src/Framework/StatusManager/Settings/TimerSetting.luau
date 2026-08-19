return function(Package)
    local Main = require(script.Parent.Parent)
    local TimerMain = require(script.Parent.Parent.Timer)
    
    local Array = {}

    if table.find(Package.SettingBlacklist, "Timer") then return true end

    for Index,Value in Package.Base do 
        if Package.Settings[Value.."Timer"] then table.insert(Array, Index) end
    end

    if #Array == 0 then return true end

    if Array[1] > 1 then 
        local Value = Array[1]
        local NewPackage = Package table.clear(NewPackage.Base)

        for i = 1, math.abs(1 - Value) - 1 do
            table.insert(NewPackage.Base, Package.Base[i])
        end

        Main.Batch(NewPackage)
    end

    TimerMain.Begin(Package, Array)
    return false
end