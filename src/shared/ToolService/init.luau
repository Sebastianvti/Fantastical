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

local function LoadComponent(ToolData)
    for Key,Value in ToolData do
        if not Components:FindFirstChild(Key) then print(Key) continue end
        -- TO DO: Check if keybind is currently being used and then get a back up if it is.

        -- Tool[Name][Value.Keybind] = {}
        -- Tool[Name][Value.Keybind] = require(Components[Key]).New(ToolData)
    end
end

function ToolService.Load(ToolData)
    local Name = ToolData.Name
    Tool[Name] = {}  

    ToolBar.AddItem(Name)
    LoadComponent(ToolData)
end

local function Recieved(Packet)
    print("Recieved")
    print(Packet)
end

Network.AddTool:onClient(Recieved)
    -- UserInputService.InputEnded:Connect(function(input)
    --     if not Tool[Name][input.KeyCode.Name] then return end
    --         Tool["Lantern"][input.KeyCode.Name]:Init()

    -- end)


return ToolService