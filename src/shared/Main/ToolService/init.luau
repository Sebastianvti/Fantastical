local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts
local UserInterfaceScripts = PlayerScripts.Client.UserInterface
local Shared = ReplicatedStorage.Shared
local Components = script.Components
local Data = script.Data

local Utility = require(script.Utility)
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
    local DataBar, InputName = Slots.ToolBar, Input.KeyCode.Name

    if DataBar[InputName] then DataBar[InputName]:Arming(InputName) end
end

local function ToolInput(Input, GPE)
    if next(Slots.EquippedTool) == nil then return end
    if GPE then return end

    local Equipped, InputName = Slots.EquippedTool, Input.KeyCode.Name
    if Equipped.Tool[InputName] then Equipped.Tool[InputName]:Init() end

end

local function TranslateNumber(Position : number)
    return Translate[Position]
end

local function IsNative(self)
    if self.Model:IsA("Tool") then return true end
    return false
end

function ToolService.Load(ToolData)
    local self = setmetatable({}, ToolService)

    self.Tool = {}
    self.Id = HttpService:GenerateGUID(false)
    self.Name = ToolData.Name

    self.ToolBar = ToolBar.New(self.Name)
    self.Model = ToolData.Model
    self.GlobalAnimations = ToolData.GlobalAnimations

    self.Holster = ToolData.Holster
    self.ToolData = ToolData.Components
    self.Equipped = false

    self.Native = IsNative(self)

    print(self)
    self:LoadComponents()
    local Position = TranslateNumber(self.ToolBar:GetPosition())
    
    Slots.ToolBar[Position] = self
end

function ToolService:LoadComponents()
    for Key,Value in self.ToolData do
        if not Components:FindFirstChild(Key) then continue end
        -- TO DO: Check if keybind is currently being used and then get a back up if it is.

        local FirstKeybind = Value.Keybinds[1]
        self.Tool[FirstKeybind] = {}

        local Preload = Utility.Preload({ToolData = self, ComponentName = Key, ComponentData = Value})
        
        self.Tool[FirstKeybind] = require(Components[Key]).New(self, Preload)
    end
end

function ToolService:Arming(InputName : string)
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid, DataBar = Character.Humanoid, Slots.ToolBar
    
    if next(Slots.EquippedTool) == nil then 
        Utility.Equip(self, Humanoid)
        Slots.EquippedTool, Slots.EquippedTool.Equipped = DataBar[InputName], true
        print("Slot "..InputName.." Equipped")

    else

        if self:NativeSwitch(Slots.EquippedTool, Humanoid, InputName) then return end
        Utility.UnEquip(Slots.EquippedTool, Humanoid)
        Slots.EquippedTool.Equipped, Slots.EquippedTool = false, {}
        print("Slot "..InputName.."Unequipped")

    end
end

function ToolService:NativeSwitch(Equipped, Humanoid, InputName)
    if self.Id == Equipped.Id then return end
    if not self.Native and not Equipped.Native and Equipped ~= self then return end
    local DataBar = Slots.ToolBar

    Utility.UnEquip(Slots.EquippedTool, Humanoid)
    Slots.EquippedTool.Equipped, Slots.EquippedTool = false, {}

    Utility.Equip(self, Humanoid)
    Slots.EquippedTool, Slots.EquippedTool.Equipped = DataBar[InputName], true
    return true
end

function ToolService.CharacterDied()
    Slots.ToolBar, Slots.EquippedTool = {}, {}
end

Network.AddTool:onClient(ToolSignal)
UserInputService.InputEnded:Connect(ToolbarInput)
UserInputService.InputEnded:Connect(ToolInput)

return ToolService