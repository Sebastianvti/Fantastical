local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local Light = {}
Light.__index = Light

function Light.New(Tool)
   local self = setmetatable({}, Light) 
   self.LightPoint = Tool.Model:FindFirstChild("LightPoint", true)
   return self
end

function Light:Init()
    print(self)
    for _,Value in self.LightPoint:GetChildren() do
        if not Value:IsA("Light") then print("bruh") return end
        print("?")
            Network.Enable:fireServer({Instance = Value})
    end
end


return Light