local Settings = {}
local SettingKeys = {}

local VerifyConflictWithOthers = require(script.Conflicts.VerifyConflict)


for _,Module in script:GetChildren() do
    local ModName = Module.Name
    SettingKeys[ModName] = require(Module)
end


function Settings.VerifySettings(Package)
    if not VerifyConflictWithOthers(Package) then warn("Status did not pass because another active status is conflicting.") return false end -- checks currently existing statuses if the one being added is compatible

    for Key, Value in pairs(Package.Status.Settings) do -- checks settings of status being passed
        if Value and SettingKeys[Key] then
            print("Running setting "..Key.." for status "..Package.Status.Name)
            if not SettingKeys[Key](Package) then return false end
        end
    end
    return true
end

return Settings