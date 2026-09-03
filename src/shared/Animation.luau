local Animation = {}
Animation.__index = Animation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local Cache = require(Shared.Cache)

local CurrentlyPlaying = {
    Enum.AnimationPriority.Core == nil,
    Enum.AnimationPriority.Idle == nil,  
    Enum.AnimationPriority.Movement == nil,
    Enum.AnimationPriority.Action == nil,
    Enum.AnimationPriority.Action2 == nil,
    Enum.AnimationPriority.Action3 == nil,
    Enum.AnimationPriority.Action4 == nil,
}

function Animation.LoadPackage(self, Package)

end

function Animation:Stopped()
    print("?")
   	if self.AnimationInstance then self.AnimationInstance.Deployed = false end
        for _, connection in pairs(self.Connections or {}) do
		connection:Disconnect()
	end
    CurrentlyPlaying[self.Animation.Priority.Value] = nil
	self.Connections = {}
end

function Animation.New(Player : Player, AnimationId : number, PlayNow : boolean?)
    local self = setmetatable({}, Animation)
    if not Player.Character then return end

    self.Player = Player
    self.Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

    self.AnimationInstance = Cache.GetAnimation()
    self.Animator = self.Humanoid.Animator
    self.AnimationName = self.AnimationInstance.ID
    self.Animation = self.AnimationInstance.Animation
    self.Animation.AnimationId = ('rbxassetid://'..AnimationId)

    self.Track = self.Animator:LoadAnimation(self.Animation)
    self.Track.Looped = false
    
    CurrentlyPlaying[self.Animation.Priority.Value] = self.AnimationName

    self.Track.Stopped:Once(function() self:Stopped() end)
    self.Connections = {}
 
    return self
end

function Animation:Play()
    if CurrentlyPlaying[self.Animation.Priority.Value] then
        return
    end
    CurrentlyPlaying[self.Animation.Priority.Value] = self.AnimationName
    self.Track:Play()
end

function Animation:Event(Event, Function)
	self.Connections[Event] = self.Track:GetMarkerReachedSignal(Event):Once(Function)
end

return Animation