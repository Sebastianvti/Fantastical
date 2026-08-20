local Timer = {}
local Main = require(script.Parent)

-- Explaination
-- A normal status which instantly adds or subtracts relies on a table called "base"
-- If a value inside this table is considered a timer, this could cause a lot of issues if there are multiple
-- This script begins in the timersetting script where it finds out which values are considered timers, then places their index in a seperate table
-- If the first timer index is above 1, then every non timer value before it will already be called.
-- The package sent to this script is purely used as a reference

-- Inside this script, the package is seperated into pieces, which are then set to timers
-- Basically {true 1, false, false, true 2}, the first true is the start point and the last false is the end point, repeating the process
-- first index is always the timer value

-- Naming Convention

local function  SplitPackage(Package, IndexPoint : number, EndNum : number)
    
    local EndPoint
    local Index = 0
    local ReturnPackage = Main.New(Package.Player, Package.Status.Name) table.clear(ReturnPackage.Base)

    table.insert(ReturnPackage.SettingBlacklist, "Timer")

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

function Timer.Begin(Package, IndexTable : table)
    local RefPackage = Package

    for Index,_ in IndexTable do

        local NewPackage = SplitPackage(Package, Index, IndexTable[Index + 1])
        Timer.CreateTimer(NewPackage, Package.Settings[Package.Base[1].."Duration"], Index)
    end
end

function Timer.CreateTimer(Package, PackTime : number, Order : number)
    
    local TimerName = Package.Status.Name
    local ActiveSheet = Package.CharacterSheet.Active_Timers

    ActiveSheet[TimerName] = {
        OsClock = os.clock(),
        Index = Order,
        Task = task.delay(PackTime, function() 
            Package.CharacterSheet.Active_Timers[TimerName] = nil
            Main.Batch(Package)
    end)
    }

end


return Timer