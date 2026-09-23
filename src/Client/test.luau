local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Tool = require(Shared.Tool)
local objectData = require(Shared.Tool.Lantern.Config)
local test = {}

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.T then
        Tool.Load(objectData)
    end
end)

return test