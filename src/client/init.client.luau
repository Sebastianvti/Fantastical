local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainServices = {
	Client = game:GetService("StarterPlayer").StarterPlayerScripts,
	Shared = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Players.LocalPlayer
local Cache = {}

for Folder,Service  in MainServices do
	for _,Module in Service[Folder]:GetDescendants() do
			if not Module:IsA("ModuleScript") then continue end

			local success, result = pcall(function()
				return require(Module)
			end)

		if success then
			if type(result) == "function" then continue end
			
			local ModName = Module.Name
			Cache[ModName] = result
	
			if Cache[ModName].Start then
				Cache[ModName].Start()
			end
			
			else
				error("Server failed to load due to a module error.".." This error came from "..(Module.Name))
		end
	end
end

UserInputService.InputBegan:Connect(function(Input, GPE)
	if Input.KeyCode == Enum.KeyCode.One then
		Cache.Animation.New(LocalPlayer, 107336788422588, true)
	end
end)

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
	if Input.KeyCode == Enum.KeyCode.D then
		ReplicatedStorage.SSEvent:FireServer(12222225)
	end
end)

-- test?