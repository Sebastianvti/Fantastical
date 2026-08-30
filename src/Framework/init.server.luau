local ServerScriptService = game:GetService("ServerScriptService")
local SoundScapeTest = require(script.SoundScapeServerTest)
local Cache = {}

for Index,Module in ServerScriptService.Framework:GetChildren() do
	if not Module:IsA("ModuleScript") then return end
	
	local ModName = Module.Name
	Cache[ModName] = require(Module)

	if Cache[ModName].Start then
		Cache[ModName].Start()
	end
end
