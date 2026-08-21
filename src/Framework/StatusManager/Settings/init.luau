local Settings = {}
local SettingKeys = {
    -- top first, bottom last
    -- if not specified then order is irrelevant
    Timer = require(script.TimerSetting),
    VerifyConflictWithOthers = (script.Conflicts.VerifyConflictWithOthers)
}

local FalseMessages = {
    Default = "Setting failed to pass."
    Timer = "No timer found in status"
    VerifyConflictWithOthers = "Statuses currently enabled are not compatible."
}

for _,Module in script:GetChildren() do
    local ModName = Module.Name
    SettingKeys[ModName] = require(Module)
end



function Settings.VerifySettings(Package) -- this is terrible
    for Key, Value in pairs(Package.Settings) do 
        if Value and SettingKeys[Key] then
            print("Running setting "..Key.." for status "..Package.Status.Name)
            if not SettingKeys[Key](Package) then warn(FalseMessages[Key] or FalseMessages[Default]) return false end
        end
    end
    return true
end

return Settings