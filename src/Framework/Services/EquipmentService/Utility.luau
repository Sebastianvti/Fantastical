local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local Tag, CosmeticCore = "Appearance", "CosmeticMain" -- this causes one issue in the future just centralize it somewhere
local Utlity = {}
-- handles server events for tools
function Utlity.NativeHolster(Package, Player)
    local Character : Model, HolsterModel : Model, Transparency = Player.Character, Package.HolsterModel, Package.Transparency and 1 or nil
    if not Character then return end
    if not Character:FindFirstChild(HolsterModel.Name) and Package.Transparency then return end -- if latency is too slow and player equips too fast
    
    for _,Value : BasePart in HolsterModel:GetChildren() do 
        if not Value:IsA("BasePart") or not Value:HasTag(Tag) then continue end
        if not Transparency then Transparency = Value:GetAttribute("Transparency") end
        
        Value.Transparency = Transparency
    end
end


Network.NativeHolster:onServer(Utlity.NativeHolster)
return Utlity