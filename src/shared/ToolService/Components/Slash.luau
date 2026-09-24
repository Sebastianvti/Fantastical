local Slash = {}
Slash.__index = Slash

function Slash.New(tool)
   local self = setmetatable({}, Slash) 
   return self
end

function Slash:Init()
    print("Slash up")
end


return Slash