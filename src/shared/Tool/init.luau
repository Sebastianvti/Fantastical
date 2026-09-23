local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)

local Components = script.Components
local Tool = {}
local Tools = {}
Tool.__index = Tool

function Tool.Load(ToolData)
    local Name = ToolData.Name
    Tools[Name] = {}  

    for Key,Value in ToolData do
        if not Components:FindFirstChild(Key) then print(Key) continue end
        -- TO DO: Check if keybind is currently being used and then get a back up if it is.
        Tools[Name][Value.Keybind] = {}
        Tools[Name][Value.Keybind] = require(Components[Key]).New(ToolData)
    end
end

    -- UserInputService.InputEnded:Connect(function(input)
    --     if not Tools[Name][input.KeyCode.Name] then return end
    --         Tools["Lantern"][input.KeyCode.Name]:Init()

    -- end)

return Tool