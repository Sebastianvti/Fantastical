local StatusManager = {}
StatusManager.__index = StatusManager

local StatusLibrary = {}
StatusLibrary.Groups = {}
local CharacterSheets = {}

local Methods = require(script.Methods)
local Template = require(script.Template)
local Utility = require(script.Utility)
local Settings = require(script.Settings)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Statuses = script.Statuses

-- Shallow tables whenever the table is not cosmetic
-- Deep tables whenever the table is cosmetic and just for organization

function StatusManager.Start()
    for _,Module in Statuses:GetChildren() do
        local ModName = Module.Name
        StatusLibrary[ModName] = require(Module)
        StatusLibrary.Groups[StatusLibrary[ModName].Group] = StatusLibrary[ModName].Name
    end
    print("Status Library Loaded",  StatusLibrary)
end

function StatusManager.Batch(self)
    if not self:DoSettings() then return end
    self:Finalize()
end

function StatusManager:Finalize()
    for _,_ in pairs(self.Base) do
       local _ = self.SubClass and Utility[self.SubClass](self) or Utility.Modify(self)
    end
end

function StatusManager:DoSettings()
    if not Settings.VerifySettings(self) then print("Setting caused ability to delay or cancel.") return false end
    return true
end

function StatusManager.New(Player : Player, StatusName : string)
    local self = setmetatable({}, StatusManager)

    self.Player = Player
    self.CharacterSheet = CharacterSheets[Player.Character]
    self.Status = StatusManager.GetStatus(StatusName)
    self.Settings = self.Status.Settings
    self.Base = Methods[self.Status.Method](self)
    self.SubClass = nil
    self.SettingBlacklist = {} -- if this status needs to do multiple setting checks, you can set certain settings on blacklist so that they are only checked a certain number of times

    print(self)
    return self
end

function  StatusManager.ClearAll(Player : Player, Name : string)
   StatusManager.ClearActive(Player, Name)
   StatusManager.ClearTimers(Player, Name)
end

function StatusManager.ClearActive(Player : Player, Name : string)
    local Character = Player.Character
    local Sheet = StatusManager.GetSheet(Character)

    for _,Value in Sheet.Active do 
        if Value == Name then

         local ValidatedStatus = StatusManager.New(Players:GetPlayerFromCharacter(Character), Name)
        
         ValidatedStatus:DoSettings()
         ValidatedStatus.Base = {"Subtract"}
         ValidatedStatus:Finalize()

        end
    end
end

function StatusManager.ClearTimers(Player : Player, Name : string)
    local Character = Player.Character
    local Sheet = StatusManager.GetSheet(Character)

    for Key,_ in Sheet.Active_Timers do 
        task.cancel(Key[Task])
        Key = nil
    end
end

function  StatusManager.GetAllActive(Name : string, Character : Model) -- checks both timer and actives
    local GetTimers = StatusManager.GetTimers(Name, Character)
    local GetActive = StatusManager.GetActive(Name, Character)
    return GetTimers + GetActive
end

function StatusManager.GetActive(Name : string, Character : Model)
    local FoundKeys = 0
    for _,Value in StatusManager.GetSheet(Character)[Active] do
        if Value == Name then FoundKeys += 1 
    end
    return FoundKeys
end

function StatusManager.GetTimers(Name : string, Character : Model)
    local FoundKeys = 0
    for Key : string,_ in StatusManager.GetSheet(Character)[Active_Timers] do
        if string.split(Key, "_")[1] == Name then FoundKeys += 1 
    end
    return FoundKeys
end

function StatusManager.GetGroup(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData.Group
end

function StatusManager.GetStatus(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData
end

function StatusManager.GetSettings(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData.Settings
end

function StatusManager.GetIncompats(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData.Incompatible
end

function StatusManager.GetIncompatGroups(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData.IncompatibleGroups
end

function StatusManager.GetWhitelist(Name : string)
    local StatusData = StatusLibrary[Name]
    if not StatusData then return warn("Status going by "..Name.." not found.") end
    return StatusData.Whitelist
end

function StatusManager.GetSheet(Character)
    return CharacterSheets[Character]
end

function StatusManager.Init(Character)
    CharacterSheets[Character] = Template
end

function StatusManager.DeInit(Character)
    CharacterSheets[Character] = nil
end

ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
    local StartTime = os.clock()

    if not StatusLibrary[StatusName] then return warn("Status going by "..StatusName.." not found.") end
    local Status = StatusManager.New(Player, StatusName)
    Status.Batch(Status)

   -- print("Processing time : ", os.clock() - StartTime)
end)

return StatusManager