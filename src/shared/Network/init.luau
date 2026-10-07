local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Main = Shared.Main

local Service = require(script.Service)
local Lync = require(Shared.Lync)

return Lync.define("Network", {
	
	-- CHAT SERVICE --
	Chatted = Lync.packet(Lync.struct({
		Sender	 = Lync.inst(),
		Message	 = Lync.str(1,300),
		Type	 = Lync.optional(Lync.enum(Service.GetEnums("Chat"))),
		Windowed = Lync.optional(Lync.bool())
	})),

	-- ADMIN --
	AllowCommands = Lync.packet(Lync.struct({
		CommandParams = Lync.map(Lync.str(1, 60), Lync.array(Lync.str(1, 100), 0, 8), 0, 200)
	})),

	AddTool = Lync.packet(Lync.struct({
		Model	 = Lync.inst(),
		Tool	 = Lync.struct({
		Name	 = Lync.enum(Service.GetEnums("Tools")),
		Components = Lync.map(
			Lync.enum(Service.GetEnums(Main.ToolService.Components)), 
			Lync.struct({
			Keybinds = Lync.optional(Lync.array(Lync.str(1, 5), 1, 5)),
			Animations = Lync.optional(Lync.map(Lync.enum(Service.GetEnums(Main.ActionService.Actions)),	Lync.array(Lync.vlq(),0,7),0,15)),
			Cooldown = Lync.optional(Lync.quant(0, 500, 0.5)),
			Audio = Lync.optional(Lync.array(Lync.vlq(), 0, 10))
		}),0,20
	)})})),
	
	Enable = Lync.packet(Lync.struct({
		Instance = Lync.inst()
	})),

	Stats = Lync.replicate(Lync.struct({
		Owner = Lync.int(-10, 2^40),
		Modifiers = Lync.map(Lync.enum(Service.GetEnums("Stats")), Lync.int(0, 100),1,100)
	})):keyBy("Owner"),

	ChangeAction = Lync.packet(Lync.struct({
		Action = Lync.enum(Service.GetEnums(Main.ActionService.Actions)),
		Time = Lync.f64()
	}))
})
