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

function StatusManager.Start()
    for _,Module in Statuses:GetChildren() do
        local ModName = Module.Name
        StatusLibrary[ModName] = require(Module)
        StatusLibrary.Groups[StatusLibrary[ModName].Group] = StatusLibrary[ModName].Name
    end
    print("Status Library Loaded",  StatusLibrary)
end

function StatusManager:Batch()
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
    self.Timer = {}
    self.Timer.AddTimer = self.Settings.AddTimer
    print(self)
    return self
end

function  StatusManager.ClearAll(Player : Player, Name : string)
    print(Player, Name)
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

function  StatusManager.GetAllActive(Name : string)
    
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
    Status:Batch()

    print("Processing time : ", os.clock() - StartTime)
    print(StatusManager.GetSheet(Player.Character))
end)

return StatusManager