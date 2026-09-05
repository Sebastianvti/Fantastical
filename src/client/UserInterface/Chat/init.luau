local Chat = {}
Chat.__index = Chat

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui = Players.LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")
local Shared = ReplicatedStorage.Shared
local Packets = Shared.Packets


local Window : CanvasGroup = UserInterface.Window

local Container : Folder = Window.Container 
local WindowTemplate = Container.MessageFrame

local ChatWindow : ScrollingFrame = Window.ChatWindow
local InputBar : TextBox = Window.InputBar

local LocalPlayer = Players.LocalPlayer
local Transparent = true
local InputConnection

local ChatPacket = require(Packets.Chat)

function Chat.New(ChatParams)
    local self = setmetatable({}, Chat)

    self.Player = ChatParams.Sender
    self.Character = ChatParams.Sender.Character
    self.Content = ChatParams.Content
    self.WindowEnabled = ChatParams.ChatWindow
    print(self)
    self:Send()
end

function Chat:Window()
    local WindowMsg : Frame = WindowTemplate:Clone()

    WindowMsg.Message.Text = "{Raspy} ".."Morlania Esfahani: "..(self.Content)
    WindowMsg.BackgroundTransparency = Transparent and 0.9 or 1
    WindowMsg.Parent = ChatWindow
    WindowMsg.Visible = true

    if Transparent then 
        Transparent = false 
    else 
        Transparent = true 
    end
end

function Chat:Send()
    if self.WindowEnabled then self:Window() end
end

local function PassMessage()
    InputBar:ReleaseFocus()

    local Information : ChatPacket.Params = {
        Sender = LocalPlayer,
        Content = InputBar.Text,
        ChatWindow = true,
    }

    Chat.New(Information)
end

local function Focused()

end

local function FocusLost(Enter)
    if Enter then PassMessage() end
end

function Chat.CharacterStart()
    print("[Chat] System Began")
end


InputBar.Focused:Connect(Focused)
InputBar.FocusLost:Connect(FocusLost)

return Chat