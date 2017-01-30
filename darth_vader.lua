if not SERVER then return end

util.PrecacheSound( "dv/theme.mp3" )

function VaderTheme( ply )
	local sid = ply:SteamID()
	
	if sid == "" then
		for k, v in pairs(player.GetAll()) do
			v:EmitSound( "dv/theme.mp3" )
		end
		timer.Create( "stopvader", 48, 1, StopVader )
	end
end

function StopVader()
	
	for k, v in pairs(player.GetAll()) do
		v:StopSound( "dv/theme.mp3" )
	end

end

hook.Add( "PlayerAuthed", "startvader", VaderTheme )