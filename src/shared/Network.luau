local Lync = require(game:GetService("ReplicatedStorage").Shared.Lync)

return  Lync.define("arena", {
    Chatted = Lync.packet(Lync.str(1,255))
})