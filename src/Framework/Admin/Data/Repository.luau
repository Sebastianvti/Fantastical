local TextService = game:GetService("TextService")
return {
    -- Check perms in 
    -- Activation is the function
    -- Chat commands ignore any player checks
    -- i know it makes it a bit longer, but keywords are their own table so that instant look ups are possible
    -- Permission 1-6, or define a rank if you want it to be locked to that rank incase the order changes

    -- FORMAT
    -- [COMMAND NAME] (PUT NAME IN COMMENT)
    -- [command in full name]
    -- [..all commands following are abbreviations or shortenings]¨
    -- If text/string is a parameter, then make it the very last, or else i have to write complicated code

    -- STATUS
    givestatus = {
        Perm = 2, Activation = "status",
        Parameters = {"Players {}", "Status : Name"}
    },
    -- CHAT COMMANDS --

    -- YELL
    yell = {
        Perm = "Player", Activation = "yell", ChatCommand = true,
        Parameters = {"Message"}
    },
    y = {
        Perm = "Player", Activation = "yell", ChatCommand = true,
        Parameters = {"Message"}
    },
    
    -- WHISPER
    whisper = {
        Perm = "Player", Activation = "whisper", ChatCommand = true,
        Parameters = {"Message"}
    },
    w = {
        Perm = "Player", Activation = "whisper", ChatCommand = true,
        Parameters = {"Message"}
    },
    
}