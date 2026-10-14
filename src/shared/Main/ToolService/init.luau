local Players = game:GetService("Players")
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
    if next(Slots.Equipped) == nil then return end
    if GPE then return end

    local Equipped, InputName = Slots.Equipped, Input.KeyCode.Name
    if Equipped.Tool[InputName] then Equipped.Tool[InputName]:Init() end

end

local function TranslateNumber(Position : number)
    return Translate[Position]
end

function ToolService.Load(ToolData)
    local self = setmetatable({}, ToolService)

    self.Tool = {}
    self.Name = ToolData.Name
    self.ToolBar = ToolBar.New(self.Name)
    self.Model = ToolData.Model
    self.Holster = ToolData.Holster
    self.ToolData = ToolData.Components

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
        self.ToolData = nil
    end
end

function ToolService:Arming(InputName : string)
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid, DataBar = Character.Humanoid, Slots.ToolBar
    
    if Character:FindFirstChild(self.Model.Name) then 
        Utility.UnEquip(self, Humanoid)
        Slots.Equipped = {}
        print("Slot "..InputName.." Equipped")
    else
        Utility.Equip(self, Humanoid)
        Slots.Equipped = DataBar[InputName]
        print("Slot "..InputName.." Unequipped")
    end
end

function ToolService.CharacterDied()
    Slots.Equipped = {}
    Slots.ToolBar = {}
end

Network.AddTool:onClient(ToolSignal)
UserInputService.InputEnded:Connect(ToolbarInput)
UserInputService.InputEnded:Connect(ToolInput)

return ToolService