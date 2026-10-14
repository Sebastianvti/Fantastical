local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local Tag = "Appearance" -- this causes one issue in the future just centralize it somewhere
local Utlity = {}
-- handles server events for tools

local function Enable(Packet) -- move somewhere else later
    local Instance = Packet.Instance
    print(Instance.Enabled)
    Instance.Enabled = not Instance.Enabled and true or false
    print(Instance.Enabled)
end

function Utlity.NativeHolster(Package, Player)
    local Character : Model, HolsterModel : Model, Transparency = Player.Character, Package.HolsterModel, Package.Transparency and 1 or nil
    if not Character then return end
    if not Character:FindFirstChild(HolsterModel.Name) and Package.Transparency then return end -- if latency is too slow and player equips too fast
    
    for _,Value : BasePart in HolsterModel:GetDescendants() do
        if not Value:IsA("BasePart") or not Value:HasTag(Tag) then continue end
        local Property, Assignment = Value:GetAttribute("Property"), Value:GetAttribute("Value")

        if type(Assignment) == "number" then
            Assignment = Package.Transparency and 1 or Value:GetAttribute("Value")
            Value[Property] = Assignment
        elseif type(Assignment) == "boolean" then
            Assignment = Package.Transparency and false or Value:GetAttribute("Value")
            Value[Property] = Assignment
        end
    end
end


Network.NativeHolster:onServer(Utlity.NativeHolster)
Network.Enable:onServer(Enable)
return Utlity