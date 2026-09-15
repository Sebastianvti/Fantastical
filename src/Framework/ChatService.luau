local ChatService = {}
ChatService.__index = ChatService

local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Network = require(Shared.Network)

local CharacterLoader = require(script.Parent.CharacterLoader)
local Admin = require(script.Parent.Admin)

local Overlap = OverlapParams.new()
local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude

local function Filter(Text, Player)
	if not Text or Text == "" then return end

	-- Filter the text for the specific player
	local success, filtered = pcall(function()
		return TextService:FilterStringAsync(Text, Player.UserId)
	end)

	if success and filtered then
		local SafeText = filtered:GetNonChatStringForBroadcastAsync()
		return SafeText
	end
end

local function ObserveArea(Character : Model)
    Overlap.FilterType = Enum.RaycastFilterType.Include
    Overlap.FilterDescendantsInstances = CharacterLoader.AllCharacters

    return workspace:GetPartBoundsInRadius(Character.HumanoidRootPart.Position, 500, Overlap)
end

local function IsLooking(Head, Character)
    local IsLooking = workspace:Raycast(Character.Head.Position, Head.Position - Character.Head.Position, Params)

    if IsLooking and IsLooking.Instance == Head then
        print("Returned true")
        return true
    else
        print("Returned false")
        return false
    end
end

function ChatService.New(Packet, Client)
    if not Client.Character then return end
    local self = setmetatable({}, ChatService)
    self.Client = Client
    self.Character = Client.Character
    self.Area = ObserveArea(self.Character)
    self.Message = Filter(Packet.Message, Client) -- optional
    self.Type = "Normal"
    self.Window = false -- if true, chat will always appear in chat box regardless of visibility to recieiver
    
    self:Inspect()
    self:Execute()
end

function ChatService:Inspect()
    if string.sub(self.Message, 1,1) ~= "/" then return end
        local Command = Admin.New(self.Client, self.Message)
        if not Command then return end

        self.Type = Command.Content.Type
        self.Message = Command.Content.Message
        self.Window = Command.Content.OverwriteWindow
end

function ChatService:Execute()
    Params.FilterDescendantsInstances = {self.Character}

    for _,Head in self.Area do
        
        local Character = Head.Parent
        local Player = Players:GetPlayerFromCharacter(Character)
        local AppearInWindow = true

        if Player ~= self.Client then AppearInWindow = IsLooking(Head, self.Character) end

       Network.Chatted:fireClient(Player, {Sender = self.Client, Message = self.Message, Type = self.Type, Windowed = self.Window or AppearInWindow})
    end
end

Network.Chatted:onServer(ChatService.New)

return ChatService