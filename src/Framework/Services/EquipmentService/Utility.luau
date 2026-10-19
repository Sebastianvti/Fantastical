local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Cache = require(Shared.Misc.Cache).New("Motor6D", Players.MaxPlayers, "Increment", 10)
local Network = require(Shared.Network)

local Tag = "Appearance" -- this causes one issue in the future just centralize it somewhere
local Utlity = {}
-- handles server events for tools

local function Enable(Packet) -- move somewhere else later
    local Instance = Packet.Instance
    Instance.Enabled = not Instance.Enabled and true or false
end

local function CustomHolster(Package, Player)
    local Character : Model, HolsterModel : Model = Player.Character, Package.HolsterModel
    if not Character then return end
    -- if not Character:FindFirstChild(HolsterModel.Name) and Package.Equipping then return end
    if not Character[HolsterModel.Name.." ToolMain"] then warn("No weld constraint found for "..HolsterModel.Name) return end

    -- local Motor6D : Motor6D = Cache:GetInstance()
    -- Motor6D.Name = "ToolWeld - "..(HolsterModel.Name)
    -- Motor6D.Parent = Character
    -- Motor6D.Part0 = Character["Right Arm"]
    -- Motor6D.Part1 = HolsterModel.Handle
    Character[HolsterModel.Name.." ToolMain"].Part0 = Character["Right Arm"]
end

local function NativeHolster(Package, Player)
    local Character : Model, HolsterModel : Model = Player.Character, Package.HolsterModel
    if not Character then return end
    if not Character:FindFirstChild(HolsterModel.Name) and Package.Transparency then return end -- if latency is too slow and player equips too fast
    
    for _,Value : BasePart in HolsterModel:GetDescendants() do
        if not Value:IsA("BasePart") or not Value:HasTag(Tag) then continue end
        local Property, Assignment = Value:GetAttribute("Property"), Value:GetAttribute("Value")

        if type(Assignment) == "number" then
            Assignment = Package.Transparency and 1 or Assignment
            Value[Property] = Assignment
        elseif type(Assignment) == "boolean" then
            Assignment = not Package.Transparency and Assignment or false
            Value[Property] = Assignment
        end
    end
end

Network.CustomHolster:onServer(CustomHolster)
Network.NativeHolster:onServer(NativeHolster)
Network.Enable:onServer(Enable)
return Utlity