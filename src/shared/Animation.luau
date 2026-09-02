local Animation
Animation.__index = Animation

function Animation.New()
    local self = setmetatable({}, Animation)

    

    return self
end

return Animation