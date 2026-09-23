local Light = {}
Light.__index = Light

function Light.New(tool)
   local self = setmetatable({}, Light) 
   return self
end

function Light:Init()
    print("Light up")
end


return Light