local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


UserInputService.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode == Enum.KeyCode.E then
	ReplicatedStorage.RemoteEvent:FireServer("Boost")
	end
	if Input.KeyCode == Enum.KeyCode.D then
		ReplicatedStorage.RemoteEvent:FireServer("UltraBoost")
	end
end)

-- test?