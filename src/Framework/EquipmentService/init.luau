local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

-- local Example = {
-- 	Name = "Lantern",
-- 	Components = {
-- 		Light = {
-- 			Keybinds = {"H"},
--             Audio = {3453535}
-- 		},
-- 	}

-- }

local EquipmentService = {}

-- local function Begin()
--     print(Example.Components)
--      Network.AddTool:fireClient(Players.TangoroaVeitayaki, {Name = Example.Name, Components = Example.Components})
-- end

-- task.delay(3, Begin)
return EquipmentService