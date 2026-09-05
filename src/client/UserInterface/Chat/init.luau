local Chat = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Network = require(ReplicatedStorage.Shared.Net)
local ClientCommands = require(script.ClientCommands)
local Finalizer = require(script.Finalizer)

local Core = PlayerGui:WaitForChild("UserInterface").Core
local Alive = workspace.Characters

local Userinterface = Core.ExperienceChat

local AppLayout = Userinterface.appLayout
local ChatinputBar = Userinterface.appLayout.chatInputBar
local Container = ChatinputBar.Background.Container

local CloseorOpenButton : TextButton = Core.TopBarApp.UnibarLeftFrame.UnibarMenu.Primary.Third.chat.IconHitArea_chat
local TextBox : TextBox = Container.TextContainer.TextBoxContainer.TextBox
local SendButton : TextButton = Container.SendButton
local ChatWindow : ScrollingFrame = Userinterface.appLayout.chatWindow.scrollingView.bottomLockedScrollView.scrollView

local Storage = Userinterface.Storage

local Prefix = "/"
local ChatWindowOpen = true

local StepBubbleChat
local WindowHideDelay
local tween
local Delays = {}
local IdTrack = {}
local BubbleTable = {}

local Ranges = {
	["whisper"] = {Visible = 5, Dotted = 10, MaxRange = 20},
	["normal"] = {Visible = 50, Dotted = 60, MaxRange = 200},
	["yell"] = {Visible = 50, Dotted = 60, MaxRange = 500},
	["thought"] = {Visible = 50, Dotted = 60, MaxRange = math.big},
}

-- this shouldve been divided into smaller modules, but heres hoping we dont need to make any big modifications to this script ever
-- max message length is 200 characters due to bubble chat


-- Explaining AssembleMessage
-- With the way Roblox chat works, every message you send actually contains your username, along with some other things, this essentially fills the gap
-- between your actual message and your username, i couldnt find a way to replicate it without directly copying it, although it makes no difference for what i am using this for

local function ChatWindowHide()
	if TextBox:IsFocused() then return end
	for _, element in pairs(AppLayout:GetDescendants()) do
		if element:GetAttribute("OriTransparency") then
			local goal = {
				 
			}
			
			if element:IsA("Frame") then
				goal.BackgroundTransparency = 1
			end

			if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
				goal.TextTransparency = 1
			end
			
			if element:IsA("ScrollingFrame") then
				goal.ScrollBarImageTransparency = 1
			end
			
			if element:IsA("ImageButton") or element:IsA("ImageLabel") then
				goal.ImageTransparency = 1
			end
			
			if element:IsA("UIStroke") then
				goal.Transparency = 1
			end

			tween = TweenService:Create(element, TweenInfo.new(0.2), goal)
			tween:Play()
		end
	end
end

local function ChatWindowShow() -- So, with the way this works, as soon as this function is called. It will hide the ui after 10 seconds
	if WindowHideDelay then task.cancel(WindowHideDelay) end
	if tween then tween:Cancel() end

	for _, element in pairs(AppLayout:GetDescendants()) do
		if element:GetAttribute("OriTransparency") then
	

			if element:IsA("Frame") then
				element.BackgroundTransparency = element:GetAttribute("OriTransparency")
			end

			if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
				element.TextTransparency = element:GetAttribute("OriTransparency")
			end

			if element:IsA("ScrollingFrame") then
				element.ScrollBarImageTransparency = element:GetAttribute("OriTransparency")
			end

			if element:IsA("ImageButton") or element:IsA("ImageLabel") then
				element.ImageTransparency = element:GetAttribute("OriTransparency")
			end

			if element:IsA("UIStroke") then
				element.Transparency = element:GetAttribute("OriTransparency")
			end

		end
	end
	
	if TextBox:IsFocused() then repeat wait(0.1) until not TextBox:IsFocused() end
	WindowHideDelay = task.delay(10, ChatWindowHide)

end

function Chat.Start(Single : boolean, player) -- SUPER CHOPPED
	if Single then
		if player.Character then
			local NewBCT = Storage.BubbleChatContainer:Clone()
			NewBCT.Name  = player.Name
			NewBCT.Parent = Userinterface.bubbleChat
			NewBCT.Adornee = player.Character.HumanoidRootPart
		end
		return
	end
	
	for _,Player in pairs(Players:GetPlayers()) do
	if Player.Character and not Userinterface.bubbleChat:FindFirstChild(Player.Name) then
	local NewBCT = Storage.BubbleChatContainer:Clone()
	NewBCT.Name  = Player.Name
	NewBCT.Parent = Userinterface.bubbleChat
	NewBCT.Adornee = Player.Character:WaitForChild("HumanoidRootPart")
		end
	end
	
	for _,Element : GuiObject in pairs(AppLayout:GetDescendants()) do -- This is REALLY ugly but there is no other solution
		if Element:IsA("Frame") and Element:GetAttribute("OriTransparency") then break end
		if Element:IsA("Frame") then
			Element:SetAttribute("OriTransparency", Element.BackgroundTransparency)
			elseif Element:IsA("ScrollingFrame") then
			Element:SetAttribute("OriTransparency", Element.ScrollBarImageTransparency)
			elseif Element:IsA("TextBox") or Element:IsA("TextButton") then
			Element:SetAttribute("OriTransparency", Element.TextTransparency)
			elseif Element:IsA("ImageButton") or Element:IsA("ImageLabel") then
			Element:SetAttribute("OriTransparency", Element.ImageTransparency)
			elseif Element:IsA("UIStroke") then
			Element:SetAttribute("OriTransparency", Element.Transparency)
		end
	end
	
	ChatWindowShow()
end

local function SizeBubbleChat(BubbleChatText : TextLabel, Frame : Frame) -- if anyone reviews this code, id love to how this can be done more easily
	-- i got really inconsistent results when i tried to wrap the text just once | Dont worry i got this - Nile
	BubbleChatText.TextWrapped = false

	local TextBoundsX, TextBoundsY = BubbleChatText.TextBounds.X, 36

	if TextBoundsX >= 312 then
		TextBoundsX = 312
	end

	Frame.Size = UDim2.new(0, TextBoundsX + 32, 0, 0)
	BubbleChatText.TextWrapped = true

	if BubbleChatText.TextBounds.Y < 36 then
		TextBoundsY = 36
	else
		local Bound = BubbleChatText.TextBounds.Y
		TextBoundsY = Bound + 16
	end

	Frame.Size = UDim2.new(0, Frame.Size.X.Offset, 0, TextBoundsY)
end

local function GetChatsOnPlayer(player)
	local BubbleChat = Userinterface.bubbleChat:FindFirstChild(player.Name).BubbleChatList
	local Num = 0
	for Index,Frame in pairs(BubbleChat:GetChildren()) do
		if Frame:IsA("Frame") then
			Num += 1
		end
	end
	
	return Num
end

local function isTableEmpty(t)
	if not t then return true end
	return next(t) == nil
end

local function IfAllTablesEmpty(bubbleTable)
	if isTableEmpty(bubbleTable) then
		return false
	end

	for player, bubbles in pairs(bubbleTable) do
		if not isTableEmpty(bubbles) then
			return true
		end
	end

	return true -- All player tables are completely empty
end

local function GetDistance(Sender)
		local Magnitude = (Sender.Character:GetPivot().Position - Players.LocalPlayer.Character:GetPivot().Position).Magnitude
	return Magnitude
end

local function GetBubbleChatState(MessageType, Sender)
	local ChatType = Ranges[MessageType]
	local PlayerDistance = GetDistance(Sender)
	
	if PlayerDistance <= ChatType["Visible"] then
		return "visible"
	elseif PlayerDistance > ChatType["Visible"] and PlayerDistance <= ChatType["Dotted"] then
		return "dotted"
	elseif PlayerDistance > ChatType["Dotted"] and PlayerDistance <= ChatType["MaxRange"] then
		return "max"
	end
end

local function FireRay(Player : Player, ChatEnum)
	
	if LocalPlayer == Player then return true end
	if ChatEnum == "yell" then return true end
	
	local LocalPosition = LocalPlayer.Character:GetPivot().Position
	local Position = Player.Character:GetPivot().Position
	local Exclude = {LocalPlayer.Character}
	
	local RaycastParamaters = RaycastParams.new()
	RaycastParamaters.FilterType = Enum.RaycastFilterType.Exclude
	RaycastParamaters.RespectCanCollide = true
	RaycastParamaters.FilterDescendantsInstances = Exclude

	
	local Direction = Position - LocalPosition
	
	local RayCast = workspace:Raycast(LocalPosition, Direction, RaycastParamaters)
	if RayCast then
		if RayCast.Instance then
			if RayCast.Instance:IsDescendantOf(Player.Character) then
				return true
			else
				return false
			end
		end
	end
	return false
end

local function GetPlayersWithinDistance(distance, ChatEnum)
	local SendTo = {}
	for _,Player in Players:GetPlayers() do
		if Player.Character then
			local Distance = (Player.Character:GetPivot().Position - LocalPlayer.Character:GetPivot().Position).Magnitude
			if Distance <= distance then
				
				local Result = FireRay(Player, ChatEnum)

				SendTo[Player.Name] = Result
			end
		end
	end
	return SendTo
end

local function SetText(MessageRaw : string, Label : TextLabel, Dotted : boolean)
	local ModifiedText
	Label:SetAttribute("OriginalText", MessageRaw)
	
	if Dotted then
		ModifiedText = "..."
	else
		ModifiedText = MessageRaw
	end
	
	return ModifiedText
end


local function AssembleMessage(template : string, player) 
	local Split = string.split(template.TextMessage.BodyText.Text, ">")
	Split[4] = player.Name..":</font"
	local forkedmessage = table.concat(Split, ">")
	
	return forkedmessage
end

local function CancelThread(player)

	if Delays[player][IdTrack[player][1]] then
		
		task.cancel(Delays[player][IdTrack[player][1]])
		
		table.remove(BubbleTable[player], 1)
		table.remove(Delays[player], 1)
		table.remove(IdTrack[player], 1)

	end
end

local function DeleteInstance(Bubble, player)
	
	table.remove(BubbleTable[player], 1)
	table.remove(Delays[player], 1)
	table.remove(IdTrack[player], 1)
	
	Bubble:Destroy()
end

local function DestroyBubbleChat(Bubble : Frame, Instant : boolean, player)
	
	if Instant then CancelThread(player) print("Destroyed Early") Bubble:Destroy()  return end
	if not Bubble then return end
	
	local waitime = 0.5
	
	local Tween = TweenService:Create(Bubble, TweenInfo.new(waitime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 0)})
	local InvisTween = TweenService:Create(Bubble.Caret, TweenInfo.new(waitime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 1})
	
	InvisTween:Play()
	Tween:Play()
	
		
	task.delay(waitime, DeleteInstance, Bubble, player)

end

local function InsertPlayerToTable(player)
	
	BubbleTable[player] = {}
	IdTrack[player] = {}
	Delays[player] = {}
	
end


local function RunBubbleChatRange()
	task.spawn(function()
	while task.wait(0.25) do
		for Player, Bubble in pairs(BubbleTable) do
				if IfAllTablesEmpty() then break end
			--	if Player == LocalPlayer then continue end
				for Index,Bubble in pairs(BubbleTable[Player]) do
					local ChatEnumState = GetBubbleChatState(Bubble[3], Player)
					
					if ChatEnumState == "visible" then
						if Bubble[3] == "whisper" and not Bubble["Heard"] then continue end
						Bubble[1].ChatBubbleFrame.Body.Text = Bubble[1].ChatBubbleFrame.Body:GetAttribute("OriginalText")
						SizeBubbleChat(Bubble[1].ChatBubbleFrame.Body, Bubble[1])
						Bubble[1].Visible = true
						
					elseif ChatEnumState == "dotted" then
						Bubble[1].ChatBubbleFrame.Body.Text = "..."
						SizeBubbleChat(Bubble[1].ChatBubbleFrame.Body, Bubble[1])
						Bubble[1].Visible = true
						
					elseif ChatEnumState == "max" then
						Bubble[1].Visible = false
						
					end
					
				end
			end
		end
	end)
end

local function Timer(NewBubbleChat, player, ChatEnum)
	
	local BubbleChatDecay = 8
	local Elapsed = os.time()

	if BubbleTable[1] then Elapsed -= BubbleTable[#BubbleTable][2] end
	if Elapsed > 8 then Elapsed = 0 end
	
	if ChatEnum == "whisper" then 
		table.insert(BubbleTable[player], {NewBubbleChat, os.time(), ChatEnum, Heard = true})
	else
		table.insert(BubbleTable[player], {NewBubbleChat, os.time(), ChatEnum})
	end

	BubbleChatDecay += Elapsed
	
	local NewId = HttpService:GenerateGUID(false)
	Delays[player][NewId] = task.delay(BubbleChatDecay, DestroyBubbleChat, NewBubbleChat, false, player)
	table.insert(IdTrack[player], NewId)
	
end

local function AddBubbleChatMessage(MessageText : string, player, ChatEnum, Dotted : boolean?, Visible : boolean?)
	if not BubbleTable[player] then InsertPlayerToTable(player) end
	if not Userinterface.bubbleChat:FindFirstChild(player.Name) then Chat.Start(true, player) end
	
	local BubbleChat = Userinterface.bubbleChat[player.Name].BubbleChatList
	local LayoutOrder = 999 LayoutOrder += 1
	local NewBubbleChat : Frame = Storage.BubbleChat:Clone()
	local BubbleChatText : TextLabel = NewBubbleChat.ChatBubbleFrame.Body
	

	BubbleChat.Parent.Adornee = player.Character.HumanoidRootPart
	NewBubbleChat.Parent = BubbleChat
	NewBubbleChat.Name = HttpService:GenerateGUID()
	BubbleChatText.Text = SetText(MessageText,BubbleChatText,Dotted)
	
	SizeBubbleChat(BubbleChatText, NewBubbleChat)
	
	local ActiveChats = GetChatsOnPlayer(player)
	if ActiveChats > 3 then
		DestroyBubbleChat(BubbleTable[player][1][1], true, player)
		Timer(NewBubbleChat, player, ChatEnum)
		
		NewBubbleChat.Visible = Visible
		
	else
		Timer(NewBubbleChat, player, ChatEnum)
		NewBubbleChat.Visible = Visible
		
	end
	RunBubbleChatRange(ChatEnum)
end

local function AddWindowMessage(MessageText : string, player)
	local Message : Frame = Storage.example:Clone()
	local LayoutOrder = 1 LayoutOrder += 1
	
	local forkedtext = AssembleMessage(Message, player)
	
	Message.Name = tostring(player.Name).."_"..LayoutOrder
	Message.TextMessage.BodyText.Text = forkedtext.." "..MessageText
	Message.TextMessage.PrefixText.Text = player.Name..":"
	Message.LayoutOrder = LayoutOrder
	Message.Visible = true
	Message.Parent = ChatWindow
	ChatWindowShow()
end

local function OnMessageRecieved(data, plr)
	local PlayerName,Bool = next(data.players)
	local Player = Players[PlayerName]

	local GetDistance = GetDistance(Player)
	local GetChatState = GetBubbleChatState(data.ChatCommand, Player)

	if GetChatState == "visible" then
		AddBubbleChatMessage(data.Message, Player, data.ChatCommand, false, true)
		
		if Bool then 
			AddWindowMessage(data.Message, Player)
			ChatWindowShow()
			Userinterface.Enabled = true
		end
		
	elseif GetChatState == "dotted" then
		AddBubbleChatMessage(data.Message, Player, data.ChatCommand, true, true)
		
		if data.ChatCommand == "yell" then
			AddWindowMessage(data.Message, Player)
			ChatWindowShow()
			Userinterface.Enabled = true
		end
		
	elseif GetChatState == "max" then
		AddBubbleChatMessage(data.Message, Player, data.ChatCommand, true, false)
		if data.ChatCommand == "yell" then
			AddWindowMessage(data.Message, Player)
			ChatWindowShow()
			Userinterface.Enabled = true
		end
		
	end
end

local function SendMessage()
	
	local chatcommand = "normal"
	local SendTo = {}
	local ChatResult
	local Range = Ranges[chatcommand]["MaxRange"]
	local msg = TextBox.Text
	TextBox.Text = ""

	msg = msg:gsub("^%s+", "")
	
	if msg:match("^%s+$") or msg == "" or msg:len() > 200  then
			print("String is only spaces, empty, or too long!")
		return
	end
	
	if string.sub(msg, 1, #Prefix) == Prefix then
		
		local commandraw = string.sub(msg, 2)
		local commandmsg = string.split(commandraw, " ")
		local command = string.lower(commandmsg[1])
		
		msg = table.concat(commandmsg, " ", 2)
		
		ChatResult = ClientCommands.IdentifyCommand(command, msg, SendTo)

		if not ChatResult then return end
		
		command = ChatResult[1]
		msg = ChatResult[2]
		Range = Ranges[command]["MaxRange"]
		chatcommand = command
		
	end
	
	msg = ClientCommands.CheckForRichText(msg)
	msg = Finalizer.Process(msg)
	SendTo = GetPlayersWithinDistance(Range, chatcommand)
	
Network.Message:send({players = SendTo, Message = msg, ChatCommand = chatcommand})
end

local function ChangeFocus()
	if TextBox:IsFocused() then
	--	TextBox:ReleaseFocus() -- dont do that
	else
		TextBox:CaptureFocus()
	end
end

local function PermacloseorOpen()
	if Userinterface.Enabled then
		Userinterface.Enabled = false
		ChatWindowShow()
	else
		Userinterface.Enabled = true
		ChatWindowShow()
	end
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Return then
		SendMessage()
		ChatWindowShow()
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Slash then
		ChatWindowShow()
		ChangeFocus()
		Userinterface.Enabled = true
	end
end)

Network.Message:on(OnMessageRecieved)
CloseorOpenButton.MouseButton1Down:Connect(PermacloseorOpen)
SendButton.MouseButton1Down:Connect(SendMessage)

return Chat