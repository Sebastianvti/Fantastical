local Data = {}
Data.__index = Data

Data.Profiles = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Templates = script.Templates
local Library = script.Parent.Library

local ProfileStore = require(Library.ProfileStore)
local CharacterTemplate = require(Templates.CharacterTemplate)
local MasterTemplate = require(Templates.MasterTemplate)

local function GetAllLinked(MasterProfile)
    return #MasterProfile.LinkedProfiles
end

function Data.GetStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local function EndMasterSession()
    
end

local function InsertCharacterProfile(ProfileName, MasterProfile)
    MasterProfile.LastUsed = ProfileName
    table.insert(MasterProfile.LinkedProfiles, ProfileName)
end

local function CreateNewProfile(Player, Master)

        local PlayerStore = ProfileStore.New(Data.GetStoreName(), CharacterTemplate)
        local GeneratedID = HttpService:GenerateGUID(false)
        local ProfileName = ("Character_"..string.sub(GeneratedID, 1, 10))

    	local Profile = PlayerStore:StartSessionAsync(ProfileName, {
		Cancel = function()
			return Player.Parent ~= Players
		end
	})

    InsertCharacterProfile(ProfileName, Master.Data)
    
    local MasterStore = ProfileStore.New(Data.GetStoreName(), MasterTemplate)
    MasterStore:EndSession()

	if Profile ~= nil then
			Profile:AddUserId(Player.UserId)
			Profile:Reconcile()

			Profile.OnSessionEnd:Connect(function()
				Data.Profiles[Player] = nil
				Player:Kick("Character data error.")
			end)

			if Player.Parent == Players then
				Data.Profiles[Player] = Profile
                print(Data.Profiles)
			else
				warn("Player was not parented to Player service")
				Profile:EndSession()
			end

		else
			Player:Kick("Character data failed to load.")
	end
end

function Data.LoadCharacter(Player : Player)

    local Master = Data.Profiles[Player]
    print(Data.Profiles)
    if GetAllLinked(Master.Data) < 1 then
        print("[Data]: Creating new profile.")
        CreateNewProfile(Player, Master)
    else

    end
end

return Data