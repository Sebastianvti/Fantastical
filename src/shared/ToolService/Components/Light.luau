local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local LocalPlayer = Players.LocalPlayer

-- local ActionService = require(Shared.ActionService)
local Animations = require(Shared.Animation)
local Cooldowns = require(Shared.Cooldown)
local Network = require(Shared.Network)

local Light = {}
Light.__index = Light

function Light.New(Tool, Preload)
    local self = setmetatable(Preload, Light)

    self.InputType = "M1"
    self.CooldownMults = {"Cooldown_Multiplier"}

    if not Tool then return self end
    
    self.Character = LocalPlayer.Character
    self.Data = Tool.ToolData.Components[script.Name]
    self.LightPoint = Tool.Model:FindFirstChild("LightPoint", true)

    -- if self.Data.Animations then  self.Animations = Animations.LoadAnimations(LocalPlayer, self.Data.Animations) end
    self.Cooldown = self.Data.Cooldown

--    ActionService.New({self.InputType, self.Data})
    print(self)
   return self
end

function Light:Init()
    -- if not Cooldowns.Begin(self) then return end
    Animations:Play(self.Animations.General)

    for _,Value in self.LightPoint:GetChildren() do
        if not Value:IsA("Light") then print("bruh") return end

        Network.Enable:fireServer({Instance = Value})
    end
end


return Light