local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local EquipmentService = require(script.Parent)

local Tag = "Appearance" -- this causes one issue in the future just centralize it somewhere
local Utlity = {}
-- handles server events for tools

local function Enable(Packet) -- move somewhere else later
    local Instance = Packet.Instance
    Instance.Enabled = not Instance.Enabled and true or false
end

local function CustomHolster(Package, Player)
    local Character : Model, HolsterModel : Model = Player.Character, Package.HolsterModel
    local Motor6D : Motor6D = Character:FindFirstChild(HolsterModel.Name.." ToolMain")

    if not Character then return end
    if not Motor6D then warn("No Motor6D found for "..HolsterModel.Name) return end

    local ItemData = EquipmentService.GetTool(HolsterModel.Name)
    local BodyPart : BasePart, AttachmentName : string = EquipmentService.GetAttachmentParent(ItemData.HeldAttachment), ItemData.HeldAttachment
    local HandleAttach, HolsterParent : Attachment = Motor6D.Part1[AttachmentName], EquipmentService.GetAttachmentParent(ItemData.Attachment)

    if not Package.Equipping then 
        Motor6D.Part0 = Character[HolsterParent]
        Motor6D.C0 = Character[HolsterParent][ItemData.Attachment].CFrame * ItemData.Offset
        Motor6D.C1 = CFrame.new(0,0,0)
        
    else

        Motor6D.Part0 = Character[BodyPart]
        Motor6D.C0 = Character[BodyPart][AttachmentName].CFrame
        Motor6D.C1 = HandleAttach.CFrame
    end
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