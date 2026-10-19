local Camera = {}
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Directory = Workspace.Directory
local Visual = Directory.Visual
local CurrentCamera, Sphere = workspace.CurrentCamera, Visual:WaitForChild("Sphere")

local TextureIds = {
	103307968442840,
	127416444780930,
	96475412423277,
	123422005318403,
	118130054589768,
	74098795408589,
	133301300649556,
	125361512131918,
--	138252054664539,
--	75519293138329,
}

local NightTexture = {
	107416023845132,
	111144577038223,
	97773946340445,
	76058466682103,
	120886955038312,
	113741483728885,
	119164812135209,
	124611827980245,
	118789454381292,
}

local CurrentTexturePack = TextureIds


UserInputService.InputBegan:Connect(function(input)
	if UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == Enum.KeyCode.F then 
		if CurrentTexturePack == TextureIds then
			CurrentTexturePack = TextureIds
			
		else
			CurrentTexturePack = TextureIds
		end
		print(CurrentTexturePack[1])
	end
end)

	RunService.RenderStepped:Connect(function()
		Sphere.CFrame = CurrentCamera.CFrame
		Sphere.TextureID = ("rbxassetid://"..CurrentTexturePack[math.random(1, #CurrentTexturePack)])
	end)

return Camera
