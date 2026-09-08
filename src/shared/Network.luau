local Lync = require(game:GetService("ReplicatedStorage").Shared.Lync)

return  Lync.define("ChatService", {
    Chatted = Lync.packet(Lync.struct({
        Sender = Lync.inst(),
        Message = Lync.str(1,300),
        Type = Lync.optional(Lync.enum({"Normal", "Yell", "Whisper"})),
        Windowed = Lync.optional(Lync.bool())
    }))
})