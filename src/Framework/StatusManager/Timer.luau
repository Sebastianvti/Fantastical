local Timer = {}
local Main = require(script.Parent)
local HttpService = game:GetService("HttpService")

-- Explaination
-- A normal status which instantly adds or subtracts relies on a table called "base"
-- If a value inside this table is considered a timer, this could cause a lot of issues if there are multiple
-- This script begins in the timersetting script where it finds out which values are considered timers, then places their index in a seperate table
-- If the first timer index is above 1, then every non timer value before it will already be called.
-- The package sent to this script is purely used as a reference

-- Inside this script, the package is seperated into pieces, which are then set to timers
-- Basically {true 1, false, false, true 2}, the first true is the start point and the last false is the end point, repeating the process
-- first index is always the timer value

local function CreateTimerStatus(Package)
    local ReturnPackage = Main.New(Package.Player, Package.Status.Name) 

    table.clear(ReturnPackage.Base)
    table.insert(ReturnPackage.SettingBlacklist, "TimerSetting")
    table.insert(ReturnPackage.SettingBlacklist, "CanStack")

    ReturnPackage.SubClass = Package.SubClass
    ReturnPackage.StatMethod = Package.StatMethod
    return ReturnPackage
end

local function  SplitPackage(Package, IndexPoint : number, EndNum : number)
    
    local EndPoint
    local Index = 0
    local ReturnPackage = CreateTimerStatus(Package)

    if not EndNum then
        EndPoint = IndexPoint
    else
        EndPoint = EndNum - 1
    end

    for _ = 1, #Package.Base + 1 do
        IndexPoint += Index
        if IndexPoint > EndPoint then return ReturnPackage end

        table.insert(ReturnPackage.Base, Package.Base[IndexPoint])

        Index += 1
    end  
end

local function CalculateTime(Package, IndexTable, Index, Instant)
    local DelayTime = 0

    if Instant then return 0 end
    if not Index then Index = #IndexTable end

    for IndexInTable = 1, #IndexTable + 1 do
        DelayTime += Package.Settings[Package.Base[IndexInTable].."Duration"]
        if IndexInTable == Index then return DelayTime end
    end
end

function Timer.RemoveOnAddSetting(Package, IndexTable, Index, Instant)
    if not Instant and not Package.Base[#IndexTable] == "Add" then return false end

    local RemoveTimer = CreateTimerStatus(Package)

    table.insert(RemoveTimer.Base, "Subtract")
    Timer.CreateTimer(RemoveTimer, CalculateTime(Package, IndexTable, Index, Instant) + RemoveTimer.Settings.SubtractDuration, Index + 1) 
end


function Timer.Begin(Package, IndexTable : table)
    for Index,_ in IndexTable do
        local NewPackage = SplitPackage(Package, Index, IndexTable[Index + 1]) -- i forgot why +1 was necessary so if anything breaks its jsut over

        Timer.CreateTimer(NewPackage, CalculateTime(Package, IndexTable, Index), Index)

        if Index == #IndexTable then 
            local _ = Package.Settings.RemoveOnAddTimer and Timer.RemoveOnAddSetting(Package, IndexTable, Index, false) 
        end
    end
end

function Timer.CreateTimer(Package, PackTime : number, Order : number)
    local TimerName = Package.Status.Name
    local TimerThread = Package.CharacterSheet.Timer_Thread
    local TimerId = HttpService:GenerateGUID(false)
    local CosmeticTimerTable = Package.CharacterSheet.Active_Timers

    table.insert(CosmeticTimerTable, Package.Name)

    TimerThread[TimerName.."_"..Order.."_"..TimerId] = {
        Name = Package.Name,
        OsClock = os.clock(),
        Duration = PackTime,
        Index = Order,
        Reactive = Package.Settings.ReactiveTimer,

        Task = task.delay(PackTime, function() 
            Package.CharacterSheet.Timer_Thread[TimerName.."_"..Order.."_"..TimerId] = nil
            table.remove(CosmeticTimerTable, table.find(CosmeticTimerTable, Package.Name))
            Main.Batch(Package)
            print("Timer Complete : ",Package.CharacterSheet)
    end)
    }
end


return Timer