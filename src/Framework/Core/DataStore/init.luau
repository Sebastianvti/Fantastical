local DataStore = {}
DataStore.__index = DataStore

DataStore.Profiles = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Templates = script.Templates
local GetStoreName = RunService:IsStudio() and "Test" or "Live"

local RandomProfile = require(script.RandomProfile)
local ProfileStore = require(script.Parent.ProfileStore)
local CharacterTemplate = require(Templates.CharacterTemplate)
local MasterTemplate = require(Templates.MasterTemplate)

local PlayerStore = ProfileStore.New(GetStoreName, CharacterTemplate)
local MasterStore = ProfileStore.New(GetStoreName, MasterTemplate)


local function GenName()
	local GeneratedID = HttpService:GenerateGUID(false)
	return ("Character_"..string.sub(GeneratedID, 1, 10))
end

function DataStore:GetAllLinked()
    return #self.LinkedProfiles
end

function DataStore.GetStoreName()
	return GetStoreName
end

function DataStore:LinkAccount(ProfileName)
	if table.find(self.LinkedProfiles, ProfileName) then return end
	 table.insert(self.LinkedProfiles, ProfileName)
end


function DataStore:StartProfile()
        local ProfileName = self.MasterProfile.Data.LastUsed or GenName()

    	self.CharacterProfile = PlayerStore:StartSessionAsync(ProfileName, {
		Cancel = function()
			return self.Player.Parent ~= Players
		end
	})

	self.MasterProfile.Data.LastUsed = ProfileName
    self:LinkAccount()

	if self.CharacterProfile then 
			self.CharacterProfile:AddUserId(self.Player.UserId)
			self.CharacterProfile:Reconcile()
			self.CharacterProfile.OnSessionEnd:Connect(function()
				DataStore.Profiles[self.Player] = nil
				self.Player:Kick("Character data error.")
			end)

			if self.Player.Parent == Players then
				DataStore.Profiles[self.Player] = self.CharacterProfile
				self.MasterProfile:EndSession()
				print("[ProfileStore]: Loaded as "..ProfileName)
				return self.CharacterProfile
			else
				warn("Player was not parented to Player service")
				self.CharacterProfile:EndSession()
			end

		else
			self.Player:Kick("Character data failed to load.")
	end
end


function DataStore:GetMaster()
	return MasterStore:GetAsync("Player_"..(self.Player.UserId))
end

function DataStore.New(Player : Player, MasterProfile)
	local self = setmetatable({}, DataStore)

	self.Player = Player
	self.MasterProfile = MasterProfile or self:GetMaster()
	self.Data = self.MasterProfile.Data
	self.LinkedProfiles = self.Data.LinkedProfiles
	self.CharacterProfile = self.Data.LastUsed
	return self	
end

return DataStore