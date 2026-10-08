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
local Utility = require(script.Utility)
local Settings = require(script.Settings)

local StatusService = {}
local StatusLibrary = {}
local CharacterSheets = {}
StatusLibrary.Groups = {}
StatusLibrary.Statuses = {}
StatusService.__index = StatusService

-- Shallow tables whenever the table is not cosmetic
-- Deep tables whenever the table is cosmetic and just for organization

function StatusService.Start(Sheet)
    CharacterSheets = Sheet
    
    for _,Module in Statuses:GetChildren() do
        local ModName = string.lower(Module.Name)
        StatusLibrary.Statuses[ModName] = require(Module)
        StatusLibrary.Groups[StatusLibrary.Statuses[ModName].Group] = StatusLibrary.Statuses[ModName].Name
    end
    print("Status Library Loaded",  StatusLibrary)
-- fix groups not grouping statuses, see loaded library
end

function StatusService.New(Player , StatusName : string)
    if Player:IsA("Model") then Player = Players:GetPlayerFromCharacter(Player) end

    local self = setmetatable({}, StatusService)

    self.Player = Player 
    self.CharacterSheet = CharacterSheets[Player.Character]
    self.Status = StatusService.GetStatus(StatusName)
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

function StatusService.Batch(self)
    if not self:DoSettings() then return end
    self:Finalize()
end

function StatusService:Finalize()
    for Index,_ in pairs(self.Base) do
       if self.SubClass then 
        Utility[self.SubClass](self, Index)  
        Utility[self.StatMethod](self, Index)
        return end

         Utility.Modify(self, Index) 
         Utility[self.StatMethod](self, Index)
    end
end

function StatusService:DoSettings()
    if not Settings.VerifySettings(self) then return false end
    return true
end

function  StatusService.ClearStatus(Character : Model, Name : string)
    StatusService.ClearActive(Character, Name)
    StatusService.ClearTimers(Character, Name)
    StatusService.ClearStack(Character, Name) -- if one exists
    StatusService.ClearThreads(Character, Name)
end

function StatusService.ClearActive(Character : Model, Name : string)
    local Mult_Sheet = StatusService.GetSheet(Character)

    for _,Value in Mult_Sheet.Active do 
        if Value == Name then

        local ValidatedStatus = StatusService.New(Character, Name)
         
        table.insert(ValidatedStatus.SettingBlacklist, "All")
        ValidatedStatus:DoSettings()
        ValidatedStatus.Base = {"Subtract"}
        ValidatedStatus:Finalize()

        end
    end
end

function StatusService.ClearStack(Character : Model, Name : string)
    local Mult_Sheet = StatusService.GetSheet(Character)
    Mult_Sheet.Active_Stacks[Name.."_Stack"] = nil
end


-- Combine clear timers into?
-- TO DO, STAT REVERSALS?
function StatusService.ClearThreads(Character, Name)
    local Mult_Sheet = StatusService.GetSheet(Character)

    for _,Thread in Mult_Sheet.Stagger_Thread do
        if Thread.Name ~= Name then continue end
        task.cancel(Thread.Task)
        Thread = nil
    end
end

function StatusService.ClearTimers(Character : Model, Name : string)
    local Mult_Sheet = StatusService.GetSheet(Character)

    for Key,Timer in Mult_Sheet.Timer_Thread do
        if Timer.Name ~= Name then continue end
        task.cancel(Timer.Task)
        table.remove(Mult_Sheet.Active_Timers, table.find(Mult_Sheet.Active_Timers, string.split(Key, "_")[1]))
        Timer = nil
    end
end

function  StatusService.GetAllActive(Name : string, Character : Model) -- checks both timer and actives
    local GetTimers = StatusService.GetTimers(Name, Character)
    local GetActive = StatusService.GetActive(Name, Character)
    return GetTimers + GetActive
end

function StatusService.GetActive(Name : string, Character : Model)
    local FoundKeys = 0
    for _,Value in StatusService.GetSheet(Character).Active do
        if Value == Name then FoundKeys += 1 end
    end
    return FoundKeys
end

function StatusService.GetTimers(Name : string, Character : Model)
    local FoundKeys = 0
    for Key : string,_ in StatusService.GetSheet(Character).Active_Timers do
        if string.split(Key, "_")[1] == Name then FoundKeys += 1 end
    end
    return FoundKeys
end


function StatusService.GetWhitelist(Name : string)
    local StatusData = StatusService.GetStatus(Name)
    if not StatusData.Result then warn(StatusData.ErrorMsg) return end
    return StatusData.Whitelist
end

function StatusService.GetStatus(Name : string)
    local StatusData = StatusLibrary.Statuses[Name]
    if not StatusData then return {Result = false, ErrorMsg = "Status going by "..Name.." not found."} end
    return StatusData
end

function StatusService.GetSheet(Character)
    return CharacterSheets[Character]
end

function StatusService.CharacterLoaded(Character)
    local Player = Players:GetPlayerFromCharacter(Character)
    local UserID = Player.UserId

    if Network.Stats:get(UserID) then return end

    Network.Stats:audience(UserID, Player)
    Network.Stats:add(UserID, {Owner = UserID, Modifiers = StatusService.GetSheet(Character).Mult_Sheet})
end




-- ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(Player, StatusName)
--     local StartTime = os.clock()
--     local Status = StatusService.GetStatus(StatusName)

--     if not Status then return warn(Status.ErrorMsg) end
--     Status = StatusService.New(Player, StatusName)

--     Status.Batch(Status)

--     print("Processing time : ", os.clock() - StartTime)
--     print("FINAL RESULT : ", StatusService.GetSheet(Player.Character))
-- end)

return StatusService