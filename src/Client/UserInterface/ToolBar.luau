local Players = game.GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")

local Interface = UserInterface.ToolBar
local Container = Interface.Container

local ToolBar = {}

local function GetPosition()
    return #Interface:GetChildren() - 2
end

function ToolBar.AddItem(Name : string)
    local Element = Container.Tool:Clone()

    Element.Name = Name
    Element.Text = (GetPosition().." - "..Name)
    Element.Parent = Interface
end

function ToolBar.RemoveItem(Name : string)
    if not Interface:FindFirstChild(Name) then return end
    
    Interface[Name]:Destroy()
end

return ToolBar