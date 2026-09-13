return {
    -- Check perms in 
    -- Activation is the function
    -- Chat commands ignore any player checks
    -- i know it makes it a bit longer, but keywords are their own table so that instant look ups are possible
    -- Permission 1-6, or define a rank if you want it to be locked to that rank incase the order changes

    -- FORMAT
    -- [COMMAND NAME] (PUT NAME IN COMMENT)
    -- [command in full name]
    -- [..all commands following are abbreviations or shortenings]

    -- STATUS
    status = {Perm = 2, Activation = "status"},
    stat = {Perm = 2, Activation = "status"},

    -- CHAT COMMANDS --

    -- YELL
    yell = {Perm = "Player", Activation = "yell", ChatCommand = true},
    y = {Perm = "Player", Activation = "yell", ChatCommand = true},

}