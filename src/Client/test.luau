local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Tool = require(Shared.ToolService)
local test = {}

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.T then
    end
end)

return test