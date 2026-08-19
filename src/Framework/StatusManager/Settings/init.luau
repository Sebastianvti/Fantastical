local Settings = {}
local SettingKeys = {
    -- top first, bottom last | if not specified then order is irrelevant to the setting
    -- DontPass is used for settings which are a dependency of other settings but not used by the main setting check, dunno if its necessary
    CanStack = require(script.CanStack),
    Timer = require(script.TimerSetting),
    VerifyConflictWithOthers = (script.Conflicts.VerifyConflict)
}

local FalseMessages = {
    Default = "Setting failed to pass.",
    Timer = "No timer found in status",
    VerifyConflictWithOthers = "Statuses currently enabled are not compatible."
}

for _,Module in script:GetDescendants() do
    local ModName = Module.Name
    SettingKeys[ModName] = require(Module)
end


return Settings