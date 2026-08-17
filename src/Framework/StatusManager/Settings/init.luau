local Settings = {}
local SettingKeys = {}

local VerifyConflictWithOthers = require(script.Conflicts.VerifyConflict)
local Timer = require(script.TimerSetting)


for _,Module in script:GetChildren() do
    local ModName = Module.Name
    SettingKeys[ModName] = require(Module)
end


function Settings.VerifySettings(Package)
    -- Do settings in order of importance, some need to be done first.
    if not VerifyConflictWithOthers(Package) then warn("Status did not pass because another active status is conflicting.") return false end -- checks currently existing statuses if the one being added is compatible
    if not Timer(Package) then return end

    -- Settings done within the loop do not need ordering
    for Key, Value in pairs(Package.Settings) do -- checks settings of status being passed
        if Value and SettingKeys[Key] then
            print("Running setting "..Key.." for status "..Package.Status.Name)
            if not SettingKeys[Key](Package) then return false end
        end
    end
    return true
end

return Settings