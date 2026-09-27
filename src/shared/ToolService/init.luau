local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts
local UserInterfaceScripts = PlayerScripts.Client.UserInterface
local Shared = ReplicatedStorage.Shared
local Components = script.Components
local Data = script.Data

local Slots = require(Data.Slots)
local Translate = require(Data.Translate)
local ToolBar = require(UserInterfaceScripts.ToolBar)
local Network = require(Shared.Network)

local ToolService = {}
ToolService.__index = ToolService

local function ToolSignal(Packet)
    ToolService.Load(Packet)
end

local function ToolbarInput(Input, GPE)
    if GPE then return end
    local DataBar = Slots.ToolBar
    local InputName = Input.KeyCode.Name

    if DataBar[InputName] then
        DataBar[InputName]:Equip()
        Slots.Equipped = DataBar[InputName]
        print("Slot "..Input.KeyCode.Name.." Equipped")
    end
end

local function ToolInput(Input, GPE)
    if next(Slots.Equipped) == nil then return end
    if GPE then return end

    local Equipped = Slots.Equipped
    local InputName = Input.KeyCode.Name

    if Equipped.Tool[InputName] then
        Equipped.Tool[InputName]:Init()
    end
end

local function TranslateNumber(Position : number)
    return Translate[Position]
end

function ToolService.Load(ToolData)
    local self = setmetatable({}, ToolService)

    self.Tool = {}
    self.Name = ToolData.Tool.Name
    self.ToolBar = ToolBar.New(self.Name)
    self.Model = ToolData.Model
    self.ToolData = ToolData.Tool
    -- self.Model.Parent = LocalPlayer.Backpack

    print(self.Model)

    self:LoadComponents()
    local Position = TranslateNumber(self.ToolBar:GetPosition())
    Slots.ToolBar[Position] = self
    print(Slots)
    -- self:Equip()
end

function ToolService:LoadComponents()
    for Key,Value in self.ToolData.Components do
        if not Components:FindFirstChild(Key) then continue end
        -- TO DO: Check if keybind is currently being used and then get a back up if it is.

        local FirstKeybind = Value.Keybinds[1]

        self.Tool[FirstKeybind] = {}
        self.Tool[FirstKeybind] = require(Components[Key]).New(self)
        self.ToolData = nil
    end
end

function ToolService:Equip()
    if not LocalPlayer.Character then return end
    local Humanoid = LocalPlayer.Character.Humanoid 
    
    Humanoid:EquipTool(self.Model)
end

function ToolService.CharacterDied()
    Slots = nil
end

Network.AddTool:onClient(ToolSignal)
UserInputService.InputEnded:Connect(ToolbarInput)
UserInputService.InputEnded:Connect(ToolInput)

return ToolService