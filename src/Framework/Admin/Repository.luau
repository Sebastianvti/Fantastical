return {
    -- Check perms in 
    -- Activation is the function
    -- Chat commands ignore any player checks
    -- i know it makes it a bit longer, but keywords are their own table so that instant look ups are possible
    status = {Perm = 2, Activation = "status", ChatCommand = false}, -- function

    -- CHAT COMMANDS --
    yell = {Perm = 5, Activation = "yell", ChatCommand = true},
    y = {Perm = 5, Activation = "yell", ChatCommand = true},

}