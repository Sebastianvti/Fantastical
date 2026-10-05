local Animation = {}
Animation.__index = Animation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local ActionService = require(Shared.ActionService)
local Cache = require(Shared.Cache)

local Playing = {

}

function Animation.LoadAnimations(Player, Package)
    for Key,Identification in Package do
        Key = Animation.New(Player, Identification)
    end
    return Package
end

function Animation:Stopped(Func)
    local _ = Func and Func() 
    -- connect events to this possibly
   	if self.AnimationInstance then self.AnimationInstance.Deployed = false end
        for _, connection in pairs(self.Connections or {}) do
		connection:Disconnect()
	end

    Playing[self.Priority] = nil
	self.Connections = {}
end

function Animation.New(Player : Player, AnimationId : number)
    local self = setmetatable({}, Animation)
    if not Player.Character then return end

    self.Player = Player
    self.Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

    self.AnimationInstance = Cache.GetAnimation()
    self.Animator = self.Humanoid.Animator
    self.Animation_Name = self.AnimationInstance.ID
    self.Animation = self.AnimationInstance.Animation
    self.Animation.AnimationId = ('rbxassetid://'..AnimationId)

    self.Track = self.Animator:LoadAnimation(self.Animation)
    self.Priority = self.Track.Priority.Name
    self.Track.Looped = false

    self.Connections = {}
    return self
end

function Animation:Play(ActionState)
    if Playing[self.Priority] then return self end
    if ActionState then ActionService.New(ActionState) end
    
    Playing[self.Priority] = self.Animation_Name

    self.Track.Stopped:Once(function() self:Stopped() end)
    self.Track:Play(0.1)
end

function Animation:Event(Event, Function)
	self.Connections[Event] = self.Track:GetMarkerReachedSignal(Event):Once(Function)
end



return Animation