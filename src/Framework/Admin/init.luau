local Admin = {}
Admin.__index = Admin

local Framework = script.Parent
local Data = script.Data

local Commands = {}

local Repository = require(Data.Repository)
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
        return Repository[Command].Activation
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
    
    self.Command = GetCommand(Text)
    if not self.Command then return end

    self.Permission = self.Command.Perm
    if not self:CheckPermission() then return end

    self.Sender = Sender
    self.Content = RemoveCommandFromString(Text)
    if not self.Command.ClientCommand then self:Execute()
    return self end

    self.Subjects = {}
    self.Args = {}
    self:Execute()
end

function Admin:CheckPermission()
    
end

local TestingPatterns = "Dude, Play3er Helvetica"
local SplitPlayerandArgs = "(.+)%s(.+)"
--local Pattern = "(%w+),*%s*(%w+)"

local Matches = {string.match(TestingPatterns, SplitPlayerandArgs)}

print(Matches)

return Admin