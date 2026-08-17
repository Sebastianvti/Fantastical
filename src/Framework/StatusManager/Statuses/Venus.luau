return {
    Name = script.Name, -- Name of the status, used for identification and referencing
    Group = "Debug", -- Group or category the status belongs to, for organizational purposes
    Method = "Permanent", -- Method of application
    RemovalMethod = nil, -- Method of removal, if you want it to differ from the application method. If nil, it will use the same method as the application.

    Settings = {
        Conflicts = true, -- Whether this status conflicts with other statuses, if dominant is false, this will not pass, if dominant is true then it will remove the other statuses and apply this one.
        Dominant = false, -- Whether this status is dominant, if true it will remove conflicting statuses when applied.
        CanStack = false,
        AddTimer = false,
        SubtractTimer = false,

        StackSize = 5, -- any number
        Priority = 3, -- 1 to 5
        AddDuration = 5,
        SubtractDuration = 5,
    },

    Incompatible = {"Tester"},
    IncompatibleGroups = {"Debug"},
    Whitelist = {},

    Sheet = {
        Damage_Multiplier = 4,
        Cooldown_Multiplier = 4,
    },

    Custom = {}
}