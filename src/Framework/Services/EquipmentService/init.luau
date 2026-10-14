local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local StoreHouse = ServerStorage.StoreHouse
local ToolStorage = StoreHouse.Tools

local Network = require(Shared.Network)
local Assign = require(script.Assign)

local Tag, CosmeticCore = "Appearance", "CosmeticMain" -- this causes one issue in the future just centralize it somewhere
local EquipmentService = {}
local ConfigCache = {}

local function InspectItem(Item) -- Welds the parts that stay on character after equip.
    if not Item:FindFirstChild(CosmeticCore) then return end
    local Index = 0
    local MainConstraint = Instance.new("WeldConstraint")

    MainConstraint.Name = Item.Name..(CosmeticCore)
    MainConstraint.Parent = Item[CosmeticCore]
    MainConstraint.Part1 = Item[CosmeticCore]

    for _,Part : BasePart in Item:GetChildren() do
        if not Part:IsA("BasePart") then continue end
        if not Part:HasTag(Tag) then continue end
        local Weld : Weld = Instance.new("WeldConstraint")  
        Index += 1

        Weld.Name = (Index).."_Weld"
        Weld.Parent = Item[CosmeticCore]

        Weld.Part0 = Item[CosmeticCore]
        Weld.Part1 = Part
    end
end

local function ConvertToModel(Tool : Tool)
    local NewModel : Model, Holsters : Folder = Instance.new("Model"), ToolStorage.Holsters
    NewModel.Name = Tool.Name
    NewModel:PivotTo(Tool:GetBoundingBox())

    for _,Inst in Tool:GetChildren() do
        if Inst:IsA("Weld") then Inst:Destroy() continue end

        if Inst:IsA("BasePart") then Inst.Anchored = false end
        Inst.Parent = NewModel
    end


    NewModel.Parent = Holsters
end

local function ReplicateTool(Player: Player, Model : Model)
    local NewModel = Model:Clone()

    NewModel.Parent = Player.Backpack
    return NewModel
end

local function Holster(Package)
    local HolsterModel : Model, Attachment : Attachment, WeldConstraint : WeldConstraint = Package.Holster:Clone(), Package.Player.Character:FindFirstChild(Package.Data.Attachment, true), Instance.new("WeldConstraint")
    -- i assume you set it up correctly so this will neeever error right

    HolsterModel.Parent = Attachment.Parent
    HolsterModel:PivotTo(Attachment.WorldCFrame * Package.Data.Offset)

    WeldConstraint.Name = Package.Data.Name.."ToolMain"
    WeldConstraint.Parent = Attachment.Parent
    WeldConstraint.Part0 = Attachment.Parent
    WeldConstraint.Part1 = HolsterModel.Handle
    if Package.Data.Holster then HolsterModel[CosmeticCore][Package.Data.Name..CosmeticCore].Part0 = Attachment.Parent end
    return HolsterModel
end

local function LoadToolbar(Player, Profile)
    for _,Value in Profile.Data.ToolBar do
        local Item = ToolStorage:FindFirstChild(Value)
        local ItemData = ConfigCache[Item.Name]
        local Packaged, HolsterModel = {Data = ItemData, Model = Item, Player = Player}

        if ItemData.Holster then
            Packaged["Holster"] = ToolStorage.Holsters[Item.Name]
            HolsterModel = Holster(Packaged)
        end

        Network.AddTool:fireClient(Player, {
            Model = ReplicateTool(Player, Item), 
            Holster = HolsterModel, 
            Name = ItemData.Name, 
            Components = ItemData.Components
        })
    end
end

function EquipmentService.CharacterLoaded(Character, Profile)
    LoadToolbar(Players:GetPlayerFromCharacter(Character), Profile)
end

function EquipmentService.Start()
    for _,Item in ToolStorage:GetChildren() do
        if not Item:FindFirstChild("Config") then continue end
        if ConfigCache[Item.Name] then warn("Duplicate tool found, skipping... "..Item.Name) continue end

        for _,Part : BasePart in ToolStorage:GetDescendants() do
            if Part:IsA("BasePart") then  -- create exemption attribute if u really need to
                Part.CanCollide = false 
                Part.CanQuery = false 
            end
        end

        ConfigCache[Item.Name] = require(Item.Config)
        if ConfigCache[Item.Name].Holster and Item:IsA("Tool") then
            local NewTool = Item:Clone()
            Assign.Classes(NewTool)
            InspectItem(NewTool) 
            ConvertToModel(NewTool) 
        end
    end
end

function EquipmentService.GetTools()
    return ConfigCache
end

function EquipmentService.GetTool(Tool : string)
    if not ConfigCache[Tool] then warn("Could not find school") return end
    return ConfigCache[Tool]
end

return EquipmentService