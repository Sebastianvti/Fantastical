local Animation = {}
Animation.__index = Animation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main
local Misc = script.Parent.Misc

local ActionService = require(Main.ActionService)
local Cache = require(Misc.Cache).New("Animation", 10, true)

local Playing = {}

local function Choose(Repo)
    local Chosen = math.random(1,#Repo)

    if not ActionService.New(Repo[Chosen].Action, Repo[Chosen].Track.Length) then return end

    Repo[Chosen]:Execute()
end

local function LoopValue(Player, Value, Action)
    local Package = {}
    for _,Id in Value do
        local NewId = Animation.New(Player, Id)

        NewId.Action = Action
        table.insert(Package, NewId)
    end
    return Package
end

function Animation.LoadAnimations(Player, Package)
    local Pack = {}

    for Key,Identifications in Package do
        Pack[Key] = LoopValue(Player, Identifications, Key)
    end
    return Pack
end

function Animation:Stopped(Func)
    local _ = Func and Func() 
        for _, connection in pairs(self.Connections or {}) do
		connection:Disconnect()
	end

    self.Animation = Cache:Withdraw(self.Animation)
    
    Playing[self.Priority] = nil
	self.Connections = {}
end

function Animation.New(Player : Player, AnimationId : number)
    local self = setmetatable({}, Animation)
    if not Player.Character then return end

    self.Player = Player
    self.Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

    self.Animation = Cache:GetInstance()
    self.Animator = self.Humanoid.Animator
    self.Animation.AnimationId = ('rbxassetid://'..AnimationId)

    self.Track = self.Animator:LoadAnimation(self.Animation)
    self.Priority = self.Track.Priority.Name
    self.Track.Looped = false

    self.Connections = {}
    return self
end

function Animation:Execute()
    if Playing[self.Priority] then return self end
    
    Playing[self.Priority] = self.Animation_Name

    self.Track.Stopped:Once(function() self:Stopped() end)
    self.Track:Play(0.1)
end

function Animation:Play(ActionState)
    if ActionState then return Choose(ActionState) end
    self:Execute()
end

function Animation:Event(Event, Function)
	self.Connections[Event] = self.Track:GetMarkerReachedSignal(Event):Once(Function)
end



return Animation