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

function ChatService.New(Packet, Client)
    if not Client.Character then return end
    local self = setmetatable({}, ChatService)
    self.Client = Client
    self.Character = Client.Character
    self.Area = ObserveArea(self.Character)
    self.Message = Filter(Packet.Message, Client) -- optional
    self.Type = "Normal"
    self.Window = false -- if true, chat will always appear in chat box regardless of visibility to recieiver
    
    if not self:Inspect() then return end
    self:Execute()
end

function ChatService:Inspect()
    if string.sub(self.Message, 1,1) ~= "/" then return true end
        local Command = Admin.New(self.Client, self.Message)
        -- if not Command then return end

        self.Type = Command.Content.Type
        self.Message = Command.Content.Message
        self.Window = Command.Content.OverwriteWindow
    return false 
end

function ChatService:Execute()
    for _,Head in self.Area do
        
        local Recipients = {}
        local Character = Head.Parent
        local Player = Players:GetPlayerFromCharacter(Character)

        table.insert(Recipients, Player)
       
    end
    Network.Chatted:fireClient(Recipients, {Sender = self.Client, Message = self.Message, Type = self.Type, Windowed = self.Window})
end

Network.Chatted:onServer(ChatService.New)

return ChatService