Written July 2026 - Present by Sebastian Qvam
Lync [Network System] - by Axp3cter

Originally began as a small project for tracking stat changes on players.

Documentation (nothing official yet)
Both server and client scripts function as a distributor for core functions such as CharacterAdded and general stat changes.

ATTRIBUTES
These must be added through Roblox.
Ignore [Boolean] | Ignores modulescript on start, must be required manually.
Client [Boolean] | Ignores a modulescript on the server. Still can be required manually.
Server [Boolean] | Ignores a modulescript on the client. Still can be required manually.

DISTRUBTED FUNCTIONS
Can be used in any script that is required automatically.
.Start() | Starts a script immediately on server launch or client launch.
.ClientStart() | Starts a script immediately on client launch.
.ServerStart() | Starts a script immediately on server launch.
.CharacterLoaded(Character) | Passes character as parameter, when the player spawns in. On server this is located in CharacterLoader, client uses main script to pass
.CharacterDied(Character) | Passes character as parameter, when player dies. On server this is located in CharacterLoader, client uses main script to pass
.StatsChanged(UserId, Modifier, OldModifiers) | Client Only, activates when stats are changed on the server
