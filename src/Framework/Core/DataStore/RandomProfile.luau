local ServerStorage = game:GetService("ServerStorage")

local StoreHouse = ServerStorage.StoreHouse

local CharacterComponents = StoreHouse.CharacterComponents
local NameConvention = CharacterComponents.NameConvention

local Gender = {"Male", "Female"}
local Xenotype = {"Baseliner", "Impid", "Yttakin"}
local RandomProfile = {}
RandomProfile.__index = RandomProfile
-- Creates a new profile for actors and stuff, only 1 function as of now

function RandomProfile.New(Profile)
    local self = setmetatable(Profile, RandomProfile)

    self.Gender = self:RollGender()
    self.Age = math.random(14, 62)
    self.FirstName = self:GetFirstName()
    self.LastName = self:GetLastName()
    self.Xenotype = self:RollXenotype()
    
    return self
end

function RandomProfile:GetFirstName()
    local NameList = require(NameConvention["First_"..(self.Gender)])
    return NameList[math.random(1,#NameList)]
end

function RandomProfile:RollXenotype()
    return Xenotype[math.random(1,#Xenotype)]
end

function RandomProfile:GetLastName()
    local NameList = require(NameConvention["Last_All"])
    return NameList[math.random(1,#NameList)]
end

function RandomProfile:RollGender()
    return Gender[math.random(1, #Gender)]
end

return RandomProfile