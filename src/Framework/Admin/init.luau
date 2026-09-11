local Admin = {}
Admin.__index = Admin

local Framework = script.Parent
local Data = script.Data

local Commands = {}

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

function Admin.Start()
    for _,Command in script.Commands:GetChildren() do
        local Name = Command.Name
        Commands[Name] = require(Command)
    end
end

function Admin:Execute()
    Commands[self.Command](self)
end

function Admin.New(Sender : Player, Text : string)
    local self = setmetatable({}, Admin)

    self.Sender = Sender
    self.Character = Sender.Character
    self.Command = GetCommand(Text)
    if not self.Command then return end

    self.Profile = DataStore.Profiles[self.Sender].Data
    self.Permission = self.Command.Perm
    if not self:CheckPermission() then warn("p") return end

    self.Content = RemoveCommandFromString(Text)
    self.Activation = self.Command.Activation
    if not self.Command.ClientCommand then self:Execute() return self end

    self.Subjects = {}
    self.Args = {}
    self:Execute()
end

function Admin:GetRank(Rank : string)
    local RankIndex = table.find(Ranks, Rank)
    if not RankIndex then warn("Could not find index from "..Rank) return end

    return RankIndex
end

function Admin:CheckPermission()
    if self.Permission <= self:GetRank(self.Profile.AdminPermission) then print("Slot had permission to run command.") return true end
    if self.Permission <= self:GetRank(DataStore.New(self.Sender).Data.AdminPermission) then print("Master Profile had permission to run command.") return true end

    warn(self.Player.Name..(" had insufficient permissions for Command: "..(self.Command)))
    return false
end

local TestingPatterns = "Dude, Play3er Helvetica"
local SplitPlayerandArgs = "(.+)%s(.+)"
--local Pattern = "(%w+),*%s*(%w+)"

local Matches = {string.match(TestingPatterns, SplitPlayerandArgs)}

print(Matches)

return Admin