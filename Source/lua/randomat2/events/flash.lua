local EVENT = {}

CreateConVar("randomat_flash_scale", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Changes the multiplier for the time scale for the event \"Everything is fast as Flash now\"")

EVENT.Title = ""
EVENT.AltTitle = "Everything is as fast as Flash now! ("..GetConVar("randomat_flash_scale"):GetInt().."% faster)"
EVENT.id = "flash"

function EVENT:Begin()
	Randomat:EventNotifySilent("Everything is as fast as Flash now! ("..GetConVar("randomat_flash_scale"):GetInt().."% faster)")
	ts = game.GetTimeScale()
	game.SetTimeScale(ts + GetConVar("randomat_flash_scale"):GetInt()/100)
end

function EVENT:End()
	game.SetTimeScale(1)
end

Randomat:register(EVENT)