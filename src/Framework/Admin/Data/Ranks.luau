return {
    ["Owner"] = 1, -- me
    ["Core"] = 2, -- anyone i deem important
    ["Admin"] = 3, -- admins
    ["Staff"] = 4, -- mod/staff
    ["High Player"] = 5, -- given to player slots
    ["Player"] = 6, 
}

-- All players have 2 admin ranks.
-- One attached to their master profile, and one attached to their character.
-- The character is useful when the player is a high rank or an important individual, but if they die its lost.
-- The  master profile is permanent and allows any command usage to their rank regardless of what the character slot has.