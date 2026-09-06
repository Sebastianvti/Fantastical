local Chat = {}
Chat.__index = Chat

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")
local Shared = ReplicatedStorage.Shared
local Packets = Shared.Packets

local Messaging = UserInterface.Messaging
local Window : CanvasGroup = Messaging.Window

local Container = Window.Container 
local ActiveContainers = Container.ActiveContainers
local BubbleChatContainer = Container.BubbleChatContainer
local BubbleChatTemplate = Container.BubbleChatTemplate
local WindowTemplate = Container.MessageTemplate


local ChatWindow : ScrollingFrame = Window.ChatWindow
local InputBar : TextBox = Window.InputBar
local MaxRange = BubbleChatContainer.MaxDistance

local Transparent = true -- On the chat window, every other message background is transparent, this just turns off when the next message background needs to be non transparent

local ChatBubbles = {} -- This is not nested, all values passed here contain all essential information seperated by underscores. PlrName_ID_Type
local Threads = {}

local RangeChart = require(script.RangeChart)
local ChatPacket = require(Packets.Chat)

local function PassMessage()
    InputBar:ReleaseFocus()

    local Information : ChatPacket.Params = {
        Sender = LocalPlayer,
        Content = InputBar.Text,
        ChatWindow = true,
        Type = "Normal",
    }

    Chat.New(Information)
end

local function FocusLost(Enter)
    if Enter then PassMessage() end
end

local function AddBubbleChat(Player : Player)
    local NewContainer = BubbleChatContainer:Clone()

    NewContainer.Parent = ActiveContainers
    NewContainer.Name = Player.Name
    NewContainer.Adornee = Player.Character.HumanoidRootPart
end

local function GetContainer(Player)
    return ActiveContainers[Player.Name].BubbleChatList
end

local function LoopRange() -- Instead of using RunService, i use a loop to detect chat messages in range, runservice has a lot of issues. This runs on a different thread
    while task.wait(1) do
        if #ChatBubbles == 0 then break end

        for _,Bubble in ChatBubbles do

            local Info = string.split(Bubble, "_")
            local Player = Players[Info[1]]
            local Character = Player.Character
            local Type = Info[3]

            --if Character == LocalPlayer.Character then continue end

            local Magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude

            if Magnitude >= MaxRange then continue end

            for Key,Value in RangeChart[Type] do
                local Ranges = string.split(Value, "-")
                
                if Magnitude >= tonumber(Ranges[1]) and Magnitude <= tonumber(Ranges[2]) then
                    Chat[Key](Player, Bubble)

                end
            end
        end
    end
end
-- PUBLIC ----------------------------------------------

function Chat.CharacterStart() -- this is a dumb solution, but :CaptureFocus DOESNT WORK for keybinds, so your text cursor doesnt show up. this is the only way to force it to do so
    -- it made me really frustrated, trying to work this out. i dont know the solution, tried everything. minor delays dont work no matter how long you set it to
    InputBar:CaptureFocus()
    InputBar:ReleaseFocus()
end

function Chat.New(ChatParams)
    local self = setmetatable({}, Chat)

    self.Player = ChatParams.Sender
    self.Character = ChatParams.Sender.Character
    self.Content = ChatParams.Content
    self.Type = "Normal"
    self.WindowEnabled = ChatParams.ChatWindow
    self.ActiveBubbles = ChatBubbles

    self:Send()
end

function Chat:Send()
    if self.WindowEnabled then self:Window() end
    self:BubbleChat()

    InputBar.Text = ""
end

function Chat:RemoveBubble(TimedOut : boolean)
    local Removing = self.ActiveBubbles[1]
    local Container = GetContainer(self.Player)

    Container[Removing]:Destroy()
    table.remove(self.ActiveBubbles, 1)

    if Threads[Removing] and not TimedOut then task.cancel(Threads[Removing]) end

    Threads[Removing] = nil
end

function Chat:LinkChat()
    local Container = GetContainer(self.Player)

    if #self.ActiveBubbles ~= 0 then -- Removes caret visibility on the chat message that is about to lose its place above the head.
    Container[self.ActiveBubbles[#self.ActiveBubbles]].Caret.Visible = false 
    end

    table.insert(self.ActiveBubbles, self.BubbleChat.Name)
    Threads[self.BubbleChat.Name] = task.delay(8, Chat.RemoveBubble, self, true)

    self.BubbleChat.Caret.Visible = true

    if #self.ActiveBubbles > 3 then self:RemoveBubble() end
    task.spawn(LoopRange)
end


function Chat:BubbleChat()
    if not ActiveContainers:FindFirstChild(self.Player.Name) then AddBubbleChat(self.Player) end

    local Container = ActiveContainers[self.Player.Name]
    self.BubbleChat = BubbleChatTemplate:Clone()

    self.BubbleChat.Name = self.Player.Name.."_"..string.sub(HttpService:GenerateGUID(false),1, 6).."_"..(self.Type) -- PlrName | RandomName | Type
    self.BubbleChat.Message.Text = self.Content
    self.BubbleChat.Visible = true
    self.BubbleChat.Parent = Container.BubbleChatList

    self.BubbleChat:SetAttribute("Message", self.Content)
    self:LinkChat()
end

function Chat:Window()
    local WindowMsg : Frame = WindowTemplate:Clone()

    WindowMsg.Name = self.Player.Name.."_"..string.sub(HttpService:GenerateGUID(false),1, 6)
    WindowMsg.Message.Text = "{Clear} ".."Iona Zierke: "..(self.Content)
    WindowMsg.BackgroundTransparency = Transparent and 0.9 or 1
    WindowMsg.Parent = ChatWindow
    WindowMsg.Visible = true

    if Transparent then Transparent = false else Transparent = true end
end

function Chat.Visible(Player, Bubble)
    local Container = GetContainer(Player)
    Container.Visible = true

    Container[Bubble].Message.Text = Container[Bubble]:GetAttribute("Message")
end

function Chat.Dotted(Player, Bubble)
    local Container = GetContainer(Player)
    Container.Visible = true

    Container[Bubble].Message.Text = "..."
end

function Chat.Hide(Player)
    local Container = GetContainer(Player)
    Container.Visible = false

end

UserInputService.InputBegan:Connect(function(Input, GPE)
    if Input.KeyCode ~= Enum.KeyCode.Slash then return end

    if InputBar:IsFocused() and not GPE then
        InputBar:ReleaseFocus()
    else
        task.wait()
         InputBar:CaptureFocus()
    end
end)
InputBar.FocusLost:Connect(FocusLost)

return Chat