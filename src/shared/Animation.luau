local Animation
Animation.__index = Animation

function Animation.New(Player : Player)
    local self = setmetatable({}, Animation)

    self.Player = Player
    self.Character = Player.Character
    self.Humanoid = self.Character:FindFirstChildOfClass("Humanoid")
    self.Priority = Enum.AnimationPriority.Action
    self.Connections = {}

    return self
end

return Animation