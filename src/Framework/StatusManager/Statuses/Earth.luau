return {
    Name = script.Name, -- Name of the status, used for identification and referencing
    Group = "Debug", -- Group or category the status belongs to, for organizational purposes
    Priority = 5, -- 1 to 5
    Method = "Permanent", -- Method of application
    RemovalMethod = nil, -- Method of removal, if you want it to differ from the application method. If nil, it will use the same method as the application.

    Settings = {
        Dominant = false, -- Whether this status is dominant, if true it will remove conflicting statuses when applied.
        CanStack = true,

        AddTimer = false, -- time it takes for status to be added 
        SubtractTimer = false, -- time it takes for status to be removed
        RemoveOnAddTimer = true, -- if the timer should start removing on add
        ReactiveTimer = false, -- if the timer counts as active while in timer (does not add stats in this state)
        Staggered = false, -- if the stats are added in portions ever few seconds

        StaggerDelay = 5,
        StaggerAmount = 10,
        StackSize = 5, -- any number
        AddDuration = 5,
        SubtractDuration = 5,
    },

    Incompatible = {},
    IncompatibleGroups = {},
    Whitelist = {},

    Sheet = {
        Damage_Multiplier = 4,
        Cooldown_Multiplier = 4,
    },

    Custom = {} -- events like if the status fails, staggers, whatever it is
}