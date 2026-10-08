return {
    Name = script.Name, -- Name of the status, used for identification and referencing
    Group = "Debug", -- Group or category the status belongs to, for organizational purposes
    Priority = 1, -- 1 to 5
    Method = "Permanent", -- Method of application
    RemovalMethod = nil, -- Method of removal, if you want it to differ from the application method. If nil, it will use the same method as the application. | UNUSED

    Settings = {
        Dominant = true, -- Whether this status is dominant, if true it will remove conflicting statuses when applied.
        CanStack = true,

        AddTimer = true, -- time it takes for status to be added 
        SubtractTimer = true, -- time it takes for status to be removed
        RemoveOnAddTimer = true, -- if the timer should start removing on add | YOU SHOULD PROBABLY ENABLE THIS FOR CANSTACK OR ELSE IT WONT REMOVE ANYTHING, canstack will keep adding until stack is full and will not remove anything
        ReactiveTimer = true, -- if the timer counts as active while in timer (does not add stats in this state)
        Staggered = false, -- if the stats are added in portions ever few seconds

        StaggerDuration = 5,
        StaggerAmount = 10,
        
        StackSize = 5, -- any number
        AddDuration = 5,
        SubtractDuration = 5,
    },

    Incompatible = {},
    IncompatibleGroups = {"Debug"},
    Whitelist = {},

    Mult_Sheet = {
        Damage_Multiplier = 4,
        Cooldown_Multiplier = 4,
    },

    Custom = {} -- events like if the status fails, staggers, whatever it is
}