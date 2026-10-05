-- Written 2026

-- TO DO
-- fix statuses not being displayed with their group on run time
-- put all threads into one table
-- do staggered timers

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Statuses = script.Statuses
local Shared = ReplicatedStorage.Shared

local Network = require(Shared.Network)
local Methods = require(script.Methods)
local Template = require(script.Template)
local Utility = require(script.Utility)
local Settings = require(script.Settings)

local StatusManager = {}
local StatusLibrary = {}
local CharacterSheets = {}
StatusLibrary.Groups = {}
StatusLibrary.Statuses = {}
StatusManager.__index = StatusManager

-- Shallow tables whenever the table is not cosmetic
-- Deep tables whenever the table is cosmetic and just for organization

function StatusManager.Start()

    for _,Module in Statuses:GetChildren() do
        local ModName = string.lower(Module.Name)
        StatusLibrary.Statuses[ModName] = require(Module)
        StatusLibrary.Groups[StatusLibrary.Statuses[ModName].Group] = StatusLibrary.Statuses[ModName].Name
    end
    print("Status Library Loaded",  StatusLibrary)
-- fix groups not grouping statuses, see loaded library
end

function StatusManager.New(Player , StatusName : string)
    if Player:IsA("Model") then Player = Players:GetPlayerFromCharacter(Player) end

    local self = setmetatable({}, StatusManager)

    self.Player = Player 
    self.CharacterSheet = CharacterSheets[Player.Character]
    self.Status = StatusManager.GetStatus(StatusName)
    if not self.Status then return end

    self.Name = self.Status.Name
    self.Group = self.Status.Group
    self.Settings = self.Status.Settings

    self.Base = Methods[self.Status.Method](self) -- how the status is applied to the active stats
    self.StatMethod = "Instant" -- how the player stats are added to the table
    self.SubClass = nil
    self.RepeatSetting = {}
    self.SettingBlacklist = {} -- if this status needs to do multiple setting checks, you can set certain settings on blacklist so that they are only checked a certain number of times

    print(self)
    return self
end

function StatusManager.Batch(self)
    if not self:DoSettings() then return end
    self:Finalize()
end

function StatusManager:Finalize()
    for Index,_ in pairs(self.Base) do
       if self.SubClass then 
        Utility[self.SubClass](self, Index)  
        Utility[self.StatMethod](self, Index)
        return end

         Utility.Modify(self, Index) 
         Utility[self.StatMethod](self, Index)
    end
end

function StatusManager:DoSettings()
    if not Settings.VerifySettings(self) then return false end
    return true
end

function  StatusManager.ClearStatus(Character : Model, Name : string)
    StatusManager.ClearActive(Character, Name)
    StatusManager.ClearTimers(Character, Name)
    StatusManager.ClearStack(Character, Name) -- if one exists
    StatusManager.ClearThreads(Character, Name)
end

function StatusManager.ClearActive(Character : Model, Name : string)
    local Sheet = StatusManager.GetSheet(Character)

    for _,Value in Sheet.Active do 
        if Value == Name then

        local ValidatedStatus = StatusManager.New(Character, Name)
         
        table.insert(ValidatedStatus.SettingBlacklist, "All")
        ValidatedStatus:DoSettings()
        ValidatedStatus.Base = {"Subtract"}
        ValidatedStatus:Finalize()

        end
    end
end

function StatusManager.ClearStack(Character : Model, Name : string)
    local Sheet = StatusManager.GetSheet(Character)
    Sheet.Active_Stacks[Name.."_Stack"] = nil
end


-- Combine clear timers into?
-- TO DO, STAT REVERSALS?
function StatusManager.ClearThreads(Character, Name)
    local Sheet = StatusManager.GetSheet(Character)

    for _,Thread in Sheet.Stagger_Thread do
        if Thread.Name ~= Name then continue end
        task.cancel(Thread.Task)
        Thread = nil
    end
end

function StatusManager.ClearTimers(Character : Model, Name : string)
    local Sheet = StatusManager.GetSheet(Character)

    for Key,Timer in Sheet.Timer_Thread do
        if Timer.Name ~= Name then continue end
        task.cancel(Timer.Task)
        table.remove(Sheet.Active_Timers, table.find(Sheet.Active_Timers, string.split(Key, "_")[1]))
        Timer = nil
    end
end

function  StatusManager.GetAllActive(Name : string, Character : Model) -- checks both timer and actives
    local GetTimers = StatusManager.GetTimers(Name, Character)
    local GetActive = StatusManager.GetActive(Name, Character)
    return GetTimers + GetActive
end

function StatusManager.GetActive(Name : string, Character : Model)
    local FoundKeys = 0
    for _,Value in StatusManager.GetSheet(Character).Active do
        if Value == Name then FoundKeys += 1 end
    end
    return FoundKeys
end

function StatusManager.GetTimers(Name : string, Character : Model)
    local FoundKeys = 0
    for Key : string,_ in StatusManager.GetSheet(Character).Active_Timers do
        if string.split(Key, "_")[1] == Name then FoundKeys += 1 end
    end
    return FoundKeys
end


function StatusManager.GetWhitelist(Name : string)
    local StatusData = StatusManager.GetStatus(Name)
    if not StatusData.Result then warn(StatusData.ErrorMsg) return end
    return StatusData.Whitelist
end

function StatusManager.GetStatus(Name : string)
    local StatusData = StatusLibrary.Statuses[Name]
    if not StatusData then return {Result = false, ErrorMsg = "Status going by "..Name.." not found."} end
    return StatusData
end

function StatusManager.GetSheet(Character)
    return CharacterSheets[Character]
end

function StatusManager.CharacterLoaded(Character)
    local Player = Players:GetPlayerFromCharacter(Character)
    local UserID = Player.UserId

    CharacterSheets[Character] = Template

    if Network.Stats:get(UserID) then return end

    Network.Stats:audience(UserID, Player)
    Network.Stats:add(UserID, {Owner = UserID, Modifiers = Template.Sheet})
end

function StatusManager.CharacterDied(Character)
    CharacterSheets[Character] = nil
end


-- ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
--     local StartTime = os.clock()
--     local Status = StatusManager.GetStatus(StatusName)

--     if not Status then return warn(Status.ErrorMsg) end
--     Status = StatusManager.New(Player, StatusName)

--     Status.Batch(Status)

--     print("Processing time : ", os.clock() - StartTime)
--     print("FINAL RESULT : ", StatusManager.GetSheet(Player.Character))
-- end)

return StatusManager