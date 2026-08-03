local ServerScriptService = game:GetService("ServerScriptService")
local Cache = {}

for Index,Module in ServerScriptService.Framework:GetChildren() do
	
	local ModName = Module.Name
	Cache[ModName] = require(Module)

	if Cache[ModName].Start then
		Cache[ModName].Start()
	end
end