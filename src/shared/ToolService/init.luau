local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer.PlayerScripts
local UserInterfaceScripts = PlayerScripts.Client.UserInterface
local Shared = ReplicatedStorage.Shared

local ToolBar = require(UserInterfaceScripts.ToolBar)
local Network = require(Shared.Network)

local Components = script.Components
local Tool = {}
local ToolService = {}
ToolService.__index = ToolService

local function ToolSignal(Packet)
    ToolService.Load(Packet)
end

local function LoadComponent(ToolData, Name)
    for Key,Value in ToolData do
        if not Components:FindFirstChild(Key) then print(Key) continue end
        -- TO DO: Check if keybind is currently being used and then get a back up if it is.

         Tool[Name][Value.Keybind] = {}
         Tool[Name][Value.Keybind] = require(Components[Key]).New(ToolData)
    end
end

function ToolService.Load(ToolData)
    local Name = ToolData.Name
    Tool[Name] = {}  

    ToolBar.AddItem(Name)
    LoadComponent(ToolData, Name)
end

Network.AddTool:onClient(ToolSignal)


return ToolService