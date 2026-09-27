local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")

local Interface = UserInterface.ToolBar
local Container = Interface.Container

local ToolBar = {}
ToolBar.__index = ToolBar

local function GetAllPositions()
    return #Interface:GetChildren() - 1
end

function ToolBar.New(Name : string)
    local self = setmetatable({}, ToolBar)

    self.Element = Container.Tool:Clone()
    self.Position = GetAllPositions()

    self.Element.Name = Name
    self.Element.Text = (self.Position.." - "..Name)
    self.Element.Parent = Interface
    self.Element.Visible = true
    return self
end

function ToolBar:GetPosition()
    local Indexed = 0
    for _,Element in Interface:GetChildren() do
        if not Element:IsA("TextLabel") then continue end
        Indexed += 1
        if Element == self.Element then return Indexed end
    end
end


function ToolBar:RemoveItem()
    if not Interface:FindFirstChild(self.Element.Name) then return end
    
    Interface[self.Element.Name]:Destroy()
end

return ToolBar