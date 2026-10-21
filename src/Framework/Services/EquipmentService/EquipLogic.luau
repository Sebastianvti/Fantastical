local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local EquipmentService = require(script.Parent)

local Tag, EquipLogic = "Appearance", {}
-- handles server events for tools

local function NativeHolster(Package, Player)
    local Character : Model, HolsterModel : Model = Player.Character, Package.HolsterModel
    if not Character then return end
    if not Character:FindFirstChild(HolsterModel.Name) and Package.Transparency then return end  -- if latency is too slow and player equips too fast

    for _,Value : BasePart in HolsterModel:GetDescendants() do
        if not Value:IsA("BasePart") or not Value:HasTag(Tag) then continue end
        local Property, Assignment = Value:GetAttribute("Property"), Value:GetAttribute("Value")

        if type(Assignment) == "number" then
            Assignment = Package.Transparency and 1 or Assignment
            Value[Property] = Assignment
            print(Value[Property])
        elseif type(Assignment) == "boolean" then
            Assignment = not Package.Transparency and Assignment or false -- can someone fix this. i just dont feel like touching this ever again
            Value[Property] = Assignment
        end
    end
end

local function StashTool(Data)
    for _,Value in Data.ItemConfig.HolsterAttachments do
        local AttachmentParent : string, Offset = EquipmentService.GetAttachmentParent(Value.Attachment), Value.Offset or CFrame.new(0,0,0)

        local Position = Offset.Position * Data.Character:GetScale()
        Offset = CFrame.new(Position) * Offset.Rotation

        Data.Motor.Part0 = Data.Character[AttachmentParent]
        Data.Motor.C0 = Data.Character[AttachmentParent][Value.Attachment].CFrame * Offset
        Data.Motor.C1 = CFrame.new(0,0,0)
    end
end

local function HoldTool(Data)
    for Part,Value in Data.ItemConfig.HeldAttachments do
        local AttachmentParent : string, Offset = EquipmentService.GetAttachmentParent(Value.Attachment), Value.Offset or CFrame.new(0,0,0)
        local HandleAttach = Data.Model[Part][Value.Attachment]

        local Position = Offset.Position * Data.Character:GetScale()
        Offset = CFrame.new(Position) * Offset.Rotation

        Data.Motor.Part0 = Data.Character[AttachmentParent]
        Data.Motor.C0 = Data.Character[AttachmentParent][Value.Attachment].CFrame * Offset
        Data.Motor.C1 = HandleAttach.CFrame
    end
end

function EquipLogic.WeldCustom(Package : {any}, Player : Player)
    local Character : Model, HolsterModel : Model = Player.Character, Package.HolsterModel
    local Motor6D : Motor6D = Character[(HolsterModel.Name.." ToolMain")]
    if not Character or not Motor6D then warn("Character or Motor6d Missing on "..Player.Name) return end

    local ItemData = EquipmentService.GetTool(HolsterModel.Name)

    if not Package.Equipping then 
        StashTool({
            Character = Character, 
            Model = HolsterModel, 
            Motor = Motor6D,
            ItemConfig = ItemData,
            ItemData = ItemData.Data
        }) 
    else 
        HoldTool({
            Character = Character, 
            Model = HolsterModel, 
            Motor = Motor6D,
            ItemConfig = ItemData,
            ItemData = ItemData.Data
        }) 
    end
end


Network.CustomHolster:onServer(EquipLogic.WeldCustom)
Network.NativeHolster:onServer(NativeHolster)
return EquipLogic