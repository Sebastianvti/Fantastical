local Antagonist = {}
Antagonist.__index = Antagonist

function Antagonist.New(Tool, Preload)
    local self = setmetatable(Preload, Antagonist)

    self.InputType = "M1"
    self.CooldownMults = {"Cooldown_Multiplier"}

    if not Tool then return self end
    
   return self
end

function Antagonist:Init()

end


return Antagonist