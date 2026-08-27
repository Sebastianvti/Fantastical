local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


UserInputService.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode == Enum.KeyCode.E then
	ReplicatedStorage.RemoteEvent:FireServer("Earth")
	end
	if Input.KeyCode == Enum.KeyCode.T then
	ReplicatedStorage.RemoteEvent:FireServer("Tester")
	end
	if Input.KeyCode == Enum.KeyCode.V then
		ReplicatedStorage.RemoteEvent:FireServer("Venus")
	end
	if Input.KeyCode == Enum.KeyCode.C then
		ReplicatedStorage.RemoteEvent:FireServer("Ceres")
	end
end)

-- test?