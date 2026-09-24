local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Service = require(script.Service)
local Lync = require(Shared.Lync)

return Lync.define("Network", {
	
	-- CHAT SERVICE --
	Chatted = Lync.packet(Lync.struct({
		Sender = Lync.inst(),
		Message = Lync.str(1,300),
		Type = Lync.optional(Lync.enum({"Normal", "Yell", "Whisper"})),
		Windowed = Lync.optional(Lync.bool())
	})),

	-- ADMIN --
	AllowCommands = Lync.packet(Lync.struct({
		CommandParams = Lync.map(Lync.str(1, 60), Lync.array(Lync.str(1, 100), 0, 8), 0, 200)
	})),

	AddTool = Lync.packet(Lync.struct({
		Name = Lync.enum(Service.GetEnums("Tools"))
	}))
})