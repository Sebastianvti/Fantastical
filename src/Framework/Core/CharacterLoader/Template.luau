return {
    Active = {}, -- Active statuses
    Active_Stacks = {}, -- cosmetic, used to track how many of each status there are as an array
    Active_Timers = {}, -- cosmetic, used to track how many timers there are as an array
    Timer_Thread = {}, -- detailed information about each timer
    Stagger_Thread = {}, -- in hindsight i shouldve had this be a value of an active key but its too late
    Threads = {}, -- threads for staggered stat methods
    Sheet = {
        Damage_Multiplier = 1,
        Cooldown_Multiplier = 2,
    },
    Cooldown = {},

}