local Admin = {}
Admin.__index = Admin

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Framework = script.Parent
local Data = script.Data

local Commands = {}

local Network = require(Shared.Network)
local Repository = require(Data.Repository)
local Ranks = require(Data.Ranks)
local DataStore = require(Framework.DataStore)

local function RemoveCommandFromString(Text: string)
   local Seperation = string.split(Text, " ")[1]
    return string.sub(Text, string.len(Seperation) + 2)
end

local function GetCommand(Text : string)
    local Lowered = string.lower(Text)
    local Seperation = string.split(Lowered, " ")[1]
    local Command = string.sub(Seperation, 2)

    if Repository[Command] then
        RemoveCommandFromString(Text, Seperation)
        return Repository[Command]
    end
end

local function GetRank(Rank : string)
    local RankIndex = table.find(Ranks, Rank)
    if not RankIndex then warn("Could not find index from "..Rank) return end
    
    return RankIndex
end

local function GetPlayersandArgs (Text: string)
    local SplitPlayerandArgs = "^(.-%w+)%w?%s(.-%w+)"
    local Matches = {string.match(Text, SplitPlayerandArgs)}
    
    return {Players = Matches[1], Args = Matches[2]}
end

local function CleanString(Text)
    return string.gsub(Text, "%p", "")
end

local function GetPlayers(Text : string)
    Text = CleanString(Text)
    local Seperation = string.split(Text, ",")
    local PlayersFound = {}

    for _,Name in Seperation do
        for _,Player in Players:GetPlayers() do
            if (string.sub(string.lower(Player.Name), 1, string.len(Name))) == string.lower(Name) then
                table.insert(PlayersFound, Player)
            end
        end
    end
    if #PlayersFound == 0 then return false end
    return PlayersFound
end

local function GetParameters(Text : string)
    Text = CleanString(Text)
    local Seperation = string.split(Text, ",")
    local ParametersFound = {}

    for _,Parameter in Seperation do
        table.insert(ParametersFound, Parameter)
    end
    return ParametersFound
end

function Admin.Start()
    for _,Command in script.Commands:GetChildren() do
        local Name = Command.Name
        Commands[Name] = require(Command)
    end

    for _,Command in Repository do
        if type(Command.Perm) ~= "string" then continue end
            Command.Perm = GetRank(Command.Perm)
    end
end

local function AutoRank()

end

function Admin.DataLoaded(Player, Profile)

    local SlotRank = GetRank(Profile.Data.AdminPermission)
    local MasterRank = GetRank(DataStore.New(Player).Data.AdminPermission)
    local Rank
    local Result = {}

    if MasterRank > SlotRank then
        Rank = SlotRank
    else
        Rank = MasterRank
    end

    for Command,Value in Repository do
        if Value.Perm < Rank then continue end
        Result[Command] = Value.Parameters
    end
    print(Result)
    Network.AllowCommands:fireClient(Player, {CommandParams = Result})
end

function Admin.New(Sender : Player, Text : string)
    local self = setmetatable({}, Admin)

    self.Sender = Sender
    self.Character = Sender.Character
    self.Command = GetCommand(Text)
    if not self.Command then warn("command does not exist") return end

    self.Profile = DataStore.Profiles[self.Sender].Data
    self.Permission = self.Command.Perm
    self.Content = RemoveCommandFromString(Text)
    self.Activation = self.Command.Activation

    if not self:CheckPermission() then return end
    if self.Command.ChatCommand then self:Execute() return self end

    local PlayersAndArgs = GetPlayersandArgs(self.Content) 
    
    self.Subjects = GetPlayers(PlayersAndArgs.Players)
    if not self.Subject then return end

    self.Args = GetParameters(Text)
    --self:Execute()
end

function Admin:Execute()
    Commands[self.Activation](self)
end

function Admin:CheckPermission()
    if self.Permission >= GetRank(self.Profile.AdminPermission) then print("Slot had permission to run command.") return true end
    if self.Permission >= GetRank(DataStore.New(self.Sender).Data.AdminPermission) then print("Master Profile had permission to run command.") return true end

    warn(self.Sender.Name..(" had insufficient permissions for Command: "..(self.Activation)))
    return false
end

return Admin