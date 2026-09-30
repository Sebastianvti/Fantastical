local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local ActionService = require(Shared.ActionService)
local Network = require(Shared.Network)
local Light = {}
Light.__index = Light

function Light.New(Tool)
   local self = setmetatable({}, Light)

   self.InputType = "Combat"
   self.Data = Tool.ToolData.Components[script.Name]
   self.LightPoint = Tool.Model:FindFirstChild("LightPoint", true)

   ActionService.New({self.InputType, self.Data})
   return self
end

function Light:Init()
    for _,Value in self.LightPoint:GetChildren() do
        if not Value:IsA("Light") then print("bruh") return end
            Network.Enable:fireServer({Instance = Value})
    end
end


return Light