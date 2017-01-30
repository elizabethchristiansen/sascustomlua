if not SERVER then return end

include( "cl_eve_hud.lua" )
AddCSLuaFile( "cl_eve_hud.lua" )

function FirstSpawn( ply )

	ply:SetNWBool( "evehud", false )
	ply:SetNWBool( "useevehud", true )
	
end

function ToggleHud( ply, str )

	local current = ply:GetNWBool( "useevehud" )

	if str == "/evehud" then
		if current == false then
			ply:SetNWBool( "useevehud", true )
		elseif current == true then
			ply:SetNWBool( "useevehud", false )
		end
	end
	
end

function EVEHudOn( ply, ent )
	if !ValidEntity( ply ) then return end
	if !ValidEntity( ent ) then return end
	
	local core = ent.SC_CoreEnt
	
	if !ValidEntity( core ) then return end
	
	umsg.Start( "EVECore", ply )
		umsg.Entity( core )
	umsg.End()
	
	ply:SetNWBool( "evehud", true )
end

function EVEHudOff( ply )

	ply:SetNWBool( "evehud", false )
	
end
	
hook.Add( "PlayerInitialSpawn", "EVEHudSpawn", FirstSpawn )
hook.Add( "PlayerSay", "ToggleEVEHud", ToggleHud )	
hook.Add( "PlayerEnteredVehicle", "StartEVEHud", EVEHudOn )
hook.Add( "PlayerLeaveVehicle", "CloseEVEHud", EVEHudOff )