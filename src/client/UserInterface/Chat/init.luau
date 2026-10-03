local Chat = {}
Chat.__index = Chat

-- TO DO
-- OPSEC
-- change the shallow table stuff

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local UserInterface = PlayerGui:WaitForChild("UserInterface")
local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)

local Window : CanvasGroup = UserInterface.Window
local Data = script.Data

local Container = Window.Container 
local ActiveContainers = Container.ActiveContainers
local BubbleChatContainer = Container.BubbleChatContainer
local BubbleChatTemplate = Container.BubbleChatTemplate
local WindowTemplate = Container.MessageTemplate


local ChatWindow : ScrollingFrame = Window.ChatWindow
local InputBar : TextBox = Window.InputBar
local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude
Params.FilterDescendantsInstances = {LocalPlayer.Character}

local Transparent = true -- On the chat window, every other message background is transparent, this just turns off when the next message background needs to be non transparent. Generally insignificant

local ChatBubbles = {} -- This is not nested, all values passed here contain all essential information seperated by underscores. PlrName_ID_Type, the reason i use this over nested is because this can be indexed more easily
local Threads = {}

local RangeChart = require(Data.RangeChart)
local Processor = require(script.ProcessMsg)
local CmdSuggest = require(script.CmdSuggest)

local function IsLooking(Head, Character)
    local IsLooking = workspace:Raycast(Character.Head.Position, Head.Position - Character.Head.Position, Params)

    if IsLooking and IsLooking.Instance == Head then
        return true
    else
        return false
    end
end

local function ReceiveMessage(Package)
    if not Package.Sender.Character then return end
    if not Package.Windowed then Package.Windowed = IsLooking(Package.Sender.Character.Head, LocalPlayer.Character) end
    if Package.Sender == LocalPlayer then Package.Windowed = true end

    local ProcessedMsg = Processor.Process(Package.Message)
    if not ProcessedMsg then return end

    Package.Message = ProcessedMsg
    Chat.New(Package)
end

local function FadeWindow(Visible)
    if InputBar:IsFocused() then Threads["Fade"] = task.delay(8, FadeWindow) return end -- minor fumble
    if Chat.TweenWindow and Chat.TweenWindow.PlaybackState == Enum.PlaybackState.Playing and Visible then Chat.TweenWindow:Cancel() end

    if not Visible then 
        Chat.TweenWindow = TweenService:Create(Window, TweenInfo.new(0.25), {GroupTransparency = 1})
    else
        Chat.TweenWindow = TweenService:Create(Window, TweenInfo.new(0.25), {GroupTransparency = 0})
    end
   
    Chat.TweenWindow:Play()
end

local function ScheduleFade()
    Threads["Fade"] = task.delay(8, FadeWindow)
end


local function ResetPlaceHolder()
    InputBar.PlaceholderText = "Press / to begin typing..."
end

local function GetMagnitude(Character : Model)
    return (LocalPlayer.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
end

local function FocusLost(Enter)
    ScheduleFade()
    if not Enter then return end

    local PreProcessedTxt = Processor.PreProcess(InputBar.Text)
    if not PreProcessedTxt then 
        task.delay(4, ResetPlaceHolder) 
        return
    end

    Network.Chatted:fireServer({Sender = LocalPlayer, Message = PreProcessedTxt})
    InputBar.Text = ""
end

local function AddContainer(Player : Player)
    local NewContainer = BubbleChatContainer:Clone()

    NewContainer.Parent = ActiveContainers
    NewContainer.Name = Player.Name
    NewContainer.Adornee = Player.Character.HumanoidRootPart
end

local function GetContainer(PlayerName : string)
    return ActiveContainers[PlayerName].BubbleChatList
end

local function LoopRange() -- Instead of using RunService, i use a loop to detect chat messages in range, runservice has a lot of issues, besides precision is not critical here. This runs on a different thread
    while task.wait(0.7) do
        if #ChatBubbles == 0 then Threads.LoopRange = nil break end

        for _,Bubble in ChatBubbles do

            local Info = string.split(Bubble, "_")
            local Player = Players:FindFirstChild(Info[1])
            if not Player then continue end -- bubbles from a player who has left will eventually clear out

            local Character = Player.Character
            local Type = Info[3]

            if Character == LocalPlayer.Character then continue end

            local Magnitude = GetMagnitude(Character)

            for Key,Value in RangeChart[Type] do
                local Minimum,Maximum = Value.Minimum,Value.Maximum
                
                if Magnitude >= Minimum and Magnitude <= Maximum then
                    Chat[Key](Player, Bubble, Type)

                end
            end
        end
    end
end
-- PUBLIC ----------------------------------------------

function Chat.CharacterAdded() -- This exists because roblox input bars are generally unreliable. But this is a good solution so its whatever
    InputBar:CaptureFocus()
    InputBar:ReleaseFocus()
end

function Chat.New(ChatParams)
    local self = setmetatable({}, Chat)

    self.Player = ChatParams.Sender
    self.Content = ChatParams.Message
    self.Type = ChatParams.Type
    self.WindowEnabled = ChatParams.Windowed
    self.ActiveBubbles = ChatBubbles

    self:Send()
end

function Chat:Send()
    if self.WindowEnabled then self:Window() end
    self:BubbleChat()

    InputBar.Text = ""
end

function Chat:BubbleChat()
    if not ActiveContainers:FindFirstChild(self.Player.Name) then AddContainer(self.Player) end

    local Container = ActiveContainers[self.Player.Name]
    Container.Adornee = self.Player.Character.HumanoidRootPart
    local StartingState = self:GetStartingState()

    self.BubbleChat = BubbleChatTemplate:Clone()

    self.BubbleChat.Name = self.Player.Name.."_"..string.sub(HttpService:GenerateGUID(false),1, 8).."_"..(self.Type) -- PlrName | RandomName | Type  In hindsight this was not as smart as i thought it was, i didnt know you could just have this as a table
    self.BubbleChat.Message.Text = self.Content
    self.BubbleChat.Visible = true
    self.BubbleChat.Parent = Container.BubbleChatList

    self.BubbleChat:SetAttribute("Message", self.Content)

    Chat[StartingState](self.Player, self.BubbleChat.Name)
    table.insert(self.ActiveBubbles, self.BubbleChat.Name)

    self:TweenChat(true)
    self:LinkChat()
end

function Chat:TweenChat(Visibility : boolean, Remove : boolean)

    local Bg,TextTr,Caret = 1,1,1

    if Visibility then 
        self.BubbleChat.Message.BackgroundTransparency = 1
        self.BubbleChat.Message.TextTransparency = 1
        self.BubbleChat.Caret.ImageTransparency = 1

        Bg,TextTr,Caret = 0.6,0,0.7
    end

    local TweenChat = TweenService:Create(self.BubbleChat.Message, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = Bg, TextTransparency = TextTr})
    local TweenCaret = TweenService:Create(self.BubbleChat.Caret, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = Caret})

    TweenCaret:Play()
    TweenChat:Play()

    if Remove then TweenChat.Completed:Once(function()
            self:RemoveBubble()
        end)
    end 
end


function Chat:Window()
    local WindowMsg : Frame = WindowTemplate:Clone()

    WindowMsg.Name = self.Player.Name.."_"..string.sub(HttpService:GenerateGUID(false),1, 6)
    WindowMsg.Message.Text = "{Hoarse} ".."Iona Zierke: "..(self.Content)
    WindowMsg.BackgroundTransparency = Transparent and 0.9 or 1
    WindowMsg.Parent = ChatWindow
    WindowMsg.Visible = true

    if Transparent then Transparent = false else Transparent = true end
    FadeWindow(true)
    ScheduleFade()
end

function Chat:RemoveBubble(TimedOut : boolean)
    local Removing = self.ActiveBubbles[1]
    if not Removing then return end

    local PlayerName = string.split(Removing, "_")[1]
    local PlrContainer : BillboardGui = GetContainer(PlayerName)

    if not PlrContainer or not PlrContainer[Removing] then return end
    PlrContainer[Removing]:Destroy()

    table.remove(self.ActiveBubbles, 1)

    if not Players:FindFirstChild(PlayerName) and not PlrContainer:FindFirstChildOfClass("Frame") then PlrContainer.Parent:Destroy() end
    if Threads[Removing] and not TimedOut then task.cancel(Threads[Removing]) end

    Threads[Removing] = nil
end

function Chat:LinkChat()
    local PlrContainer = GetContainer(self.Player.Name)

    if #self.ActiveBubbles ~= 0 then -- Removes caret visibility on the chat message that is about to lose its place above the head.
    PlrContainer[self.ActiveBubbles[#self.ActiveBubbles]].Caret.Visible = false 
    end

    Threads[self.BubbleChat.Name] = task.delay(8, Chat.TweenChat, self, false, true)
    self.BubbleChat.Caret.Visible = true

    if #self.ActiveBubbles > 3 then self:RemoveBubble() end
    if Threads.LoopRange then return end
    Threads["LoopRange"] = task.spawn(LoopRange)
end

function Chat:GetStartingState()
    for Key,Value in RangeChart[self.Type] do
        local Minimum,Maximum = Value.Minimum,Value.Maximum
        local Magnitude = GetMagnitude(self.Player.Character)

        if Magnitude >= Minimum and Magnitude <= Maximum then
            return Key
        end
    end
    return "Hide"
end

function Chat.Visible(Player, Bubble, Type)
    if Type == "Whisper" then return end

    local PlrContainer = GetContainer(Player.Name)
    PlrContainer.Visible = true
    PlrContainer[Bubble].Message.Text = PlrContainer[Bubble]:GetAttribute("Message")
end

function Chat.Dotted(Player, Bubble, Type)
    local PlrContainer = GetContainer(Player.Name)
    PlrContainer.Visible = true

    PlrContainer[Bubble].Message.Text = "..."
end

function Chat.Hide(Player)
    local PlrContainer = GetContainer(Player.Name)
    
    PlrContainer.Visible = false
end

UserInputService.InputBegan:Connect(function(Input, GPE)
    if Input.KeyCode ~= Enum.KeyCode.Slash then return end

    if InputBar:IsFocused() and not GPE then
        InputBar:ReleaseFocus()
    else
        if Threads["HideInterface"] then task.cancel(Threads["HideInterface"]) 
            Threads["HideInterface"] = nil 

        end
            Window.Visible = true
            FadeWindow(true)
            InputBar:CaptureFocus()
    end
end)


InputBar.FocusLost:Connect(FocusLost)
Network.AllowCommands:onClient(CmdSuggest.Update)
Network.Chatted:onClient(ReceiveMessage)
    
return Chat