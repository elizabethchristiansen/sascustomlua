if not SERVER then return end

include( "cl_shipinfo.lua" )
AddCSLuaFile( "autorun/cl_shipinfo.lua" )

function SetDefault( ply )

	ply:SetNWBool( "scinfo", true )
	ply:SetNWBool( "invehicle", false )
	
end

function ShowShipInfo( ply, ent )
	
	local core = ent.SC_CoreEnt
	if core == nil then return end
	
	ply:SetNWEntity( "core", core )
	ply:SetNWBool( "invehicle", true )
	
end

function HideShipInfo( ply )

	ply:SetNWBool( "invehicle", false )

end

function ToggleShipInfo( ply, str )

	if str == "/showshipinfo" then
		ply:SetNWBool( "scinfo", true )
	elseif str == "/hideshipinfo" then
		ply:SetNWBool( "scinfo", false )
	end

end

hook.Add( "PlayerInitialSpawn", "PlayerHasSpawned", SetDefault )
hook.Add( "PlayerSay", "ToggleDisplay", ToggleShipInfo )
hook.Add( "PlayerEnteredVehicle", "ShowSCDisplay", ShowShipInfo )
hook.Add( "PlayerLeaveVehicle", "HideSCDisplay", HideShipInfo )