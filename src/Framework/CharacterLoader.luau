local CharacterLoader = {}
CharacterLoader.AllCharacters = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local StoreHouse = ServerStorage.StoreHouse

local Lync = require(Shared.Lync)
local Network = require(Shared.Network)
local StatusService = require(script.Parent.StatusService)

local function Tester(Player)
	Network.Fighters:audience(Player.UserId, Player)
    Network.Fighters:add(Player.UserId, { owner = Player.UserId, name = Player.Name, hp = 100 })
	task.wait(1)
	Network.Fighters:update(Player.UserId, {hp = 5 })
end

function CharacterLoader.CharacterAdded(Character)
	warn("Chracter Loaded")
	local Player = Players:GetPlayerFromCharacter(Character)
	task.delay(5, Tester, Player)
	StatusService.Init(Character)
	table.insert(CharacterLoader.AllCharacters, Character.Head) -- We track the head because only chat service needs this.
end

function CharacterLoader.CharacterDied(Character)
	StatusService.DeInit(Character)
	table.remove(CharacterLoader.AllCharacters, table.find(CharacterLoader.AllCharacters, Character.Head))
end

return CharacterLoader
