local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main
local LocalPlayer = Players.LocalPlayer

local Network = require(Shared.Network)
local Animations = require(Shared.Animation)
local Cooldown = require(Main.Cooldown)
local Utility = {}

local function NativeHolster(self, Humanoid : Humanoid, Equipping)
    if not Equipping then Humanoid:UnequipTools() else Humanoid:EquipTool(self.Model) end
    if not self.Holster then return end

    Network.NativeHolster:fireServer({HolsterModel = self.Holster, Transparency = Equipping or false})
end

function Utility.Equip(self, Humanoid : Humanoid)
    if self.Model:IsA("Tool") then NativeHolster(self, Humanoid, true) return end
    if not self.Holster then return end
    if not self.GlobalAnimations or not self.GlobalAnimations.Equip then Network.CustomHolster:fireServer({HolsterModel = self.Model, Equipping = true}) return end

end

function Utility.UnEquip(self, Humanoid : Humanoid)
    if self.Model:IsA("Tool") then NativeHolster(self, Humanoid, false) return end
    if not self.Holster then return end
    -- if not self.GlobalAnimations or not self.GlobalAnimations.Equip then Network.CustomHolster:fireServer({HolsterModel = self.Model, Equipping = false}) return end

end

function Utility.Preload(Data)
    local Preload = {
        Main = Data.ToolData.Name,
        Name = Data.ComponentName
    }

    for Key,_ in Data.ComponentData do
        if not Utility[Key] then continue end
        Utility[Key](Preload, Data)
    end

    return Preload
end

function Utility.Animations(Preload, Data)
    Preload["Animations"] = Animations.LoadAnimations(LocalPlayer, Data.ComponentData.Animations)
end

function Utility.Cooldown(Preload, Data)
    Preload["Cooldown"] = Cooldown.New(Data, Preload)
end

return Utility