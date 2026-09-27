local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ToolService = Shared.ToolService
local StoreHouse = ServerStorage.StoreHouse
local ToolStorage = StoreHouse.Tools
local Network = require(Shared.Network)

local EquipmentService = {}
local ConfigCache = {}

local function ReplicateTool(Model : Model)
    local NewModel = Model:Clone()
    NewModel.Parent = ToolService.Models
    return NewModel
end

local function LoadToolbar(Player, Profile)
    for _,Value in Profile.Data.ToolBar do
        local Item = ToolStorage:FindFirstChild(Value)
        local ItemData = ConfigCache[Item.Name]

        Network.AddTool:fireClient(Player, {Model = ReplicateTool(Item), Tool = ItemData})
    end
end

function EquipmentService.DataLoaded(Player, Profile)
    LoadToolbar(Player, Profile)
end

function EquipmentService.Start()
    for _,Item in ToolStorage:GetChildren() do
        if not Item.Config then continue end

        ConfigCache[Item.Name] = require(Item.Config)
    end
end

return EquipmentService