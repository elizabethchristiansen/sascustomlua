if not SERVER then return end

include( "cl_aggression.lua" )
AddCSLuaFile( "autorun/cl_aggression.lua" )

local globalaggressiont = 90
local aggressiont = 60

function FirstSpawn( ply )

	ply:SetNWString("aggression", "none")
	ply:SetNWBool("showaggrotable", true)
	ply:SetNWString("location", "earth")
	ply:SetNWInt("aggrotime", 0)
	ply:SetNWInt("aggrorem", 0)
	ply:SetNWString("hudstring", "hud string")
	ply:SetNWBool("usehud", false)
	
end

function Aggression( ply )
	
	local aggression = "aggression"

	if ValidEntity( ply ) and ply:IsPlayer() and ply:Alive() then
		ply:SetNWString("aggression", aggression)
		ply:SetNWInt("aggrotime", CurTime())
		AlertPlayers( ply, aggression )
		UpdateHud( ply, "start" )
	end
	
end

function GlobalAggression( ply )

	local aggression = "global"

	if ValidEntity( ply ) and ply:IsPlayer() and ply:Alive() then
		ply:SetNWString("aggression", aggression)
		ply:SetNWInt("aggrotime", CurTime())
		AlertPlayers( ply, aggression )
		UpdateHud( ply, "start" )
	end

end

function CheckPos( ply )

	local earth = Vector( -5678.3, -3819.8, -13.72 )
	local returnarg = "wtf"

	if ValidEntity( ply ) and ply:IsPlayer() then
		if ply:GetPos():Distance( earth ) > 3000 then
			ply:SetNWString("location", "space")
			returnarg = "space"
		else
			ply:SetNWString("location", "earth")
			returnarg = "earth"
		end
	else		
		for _, plyr in pairs(player.GetAll()) do
			if plyr:GetPos():Distance( earth ) > 3000 then
				plyr:SetNWString("location", "space")
				if plyr:GetNWString("aggression") == "none" then
					Aggression( plyr )
				end
			else
				plyr:SetNWString("location", "earth")
			end
		end
	end
	
	return returnarg
	
end

function CheckAggressionTimer()
	
	for _, ply in pairs(player.GetAll()) do
		local aggro = ply:GetNWString("aggression")
		local loc = ply:GetNWString("location")
		if aggro != "none" then
			local time = ply:GetNWInt("aggrotime")
			if loc == "earth" then 
				if aggro == "aggression" then
					if ( (CurTime() - time) >= aggressiont ) then 
						ResetAggression( ply )
					else
						timerem = CurTime() - time
						realtime = math.Round(aggressiont - timerem)
						ply:SetNWInt("aggrorem", realtime)
						UpdateHud( ply, "update", time )
					end
				elseif aggro == "global" then
					if ( (CurTime() - time) >= globalaggressiont ) then 
						ResetAggression( ply )
					else
						timerem = CurTime() - time
						realtime = math.Round(globalaggressiont - timerem)
						ply:SetNWInt("aggrorem", realtime)
						UpdateHud( ply, "update", time )
					end
				end
			elseif loc == "space" then
				ResetTimer( ply )
				UpdateHud( ply, "start" )
			end
		end
	end
			
end

function ResetTimer( ply )

	ply:SetNWInt("aggrotime", CurTime())
	
end

function ResetAggression( ply )

	local aggression = "none"

	if ValidEntity( ply ) then
		if ply:IsPlayer() then
			ply:SetNWString("aggression", aggression)
			AlertPlayers( ply, aggression )
			UpdateHud( ply, "end" )
		end
	end
	
end

function AlertPlayers( ply, aggression )
	
	for _, plyr in pairs(player.GetAll()) do
		if plyr == ply then
			umsg.Start( "plyaggression", ply )
				umsg.String( aggression )
			umsg.End()
		else
			umsg.Start( "aggression", plyr )
				umsg.String( aggression )
				umsg.String( ply:Nick() )
			umsg.End()
		end
	end
	
end

function AgroTable( ply, str )
	
	if str == "/showaggro" then
		ply:SetNWBool("showaggrotable", true)
	elseif str == "/hideaggro" then
		ply:SetNWBool("showaggrotable", false)
	end
	
end

function UpdateHud( ply, func, time )
	local aggression = ply:GetNWString("aggression")
	local location = ply:GetNWString("location")
	
	if func == "start" then
		if aggression == "aggression" then
			hudstring = "Aggression"
			tablestring = ply:Nick()
		elseif aggression == "global" then
			hudstring = "Global Aggression"
			tablestring = ply:Nick()
		end
		usehud = true
	elseif func == "update" then
		if aggression == "aggression" then
			hudstring = "Aggression Countdown: "..tostring(time).." Seconds"
		elseif aggression == "global" then
			hudstring = "Global Aggression Countdown: "..tostring(time).." Seconds"
		end
		tablestring = ply:Nick().." ("..tostring(time).." Sec)"
		usehud = true
	elseif func == "end" then
		tablestring = ply:Nick()
		usehud = false
	end

	ply:SetNWString("hudstring", hudstring)
	ply:SetNWString("tablestring", tablestring)
	ply:SetNWBool("usehud", usehud)

end

function PlayerDied( victim, weapon, killer )

	if victim != killer then
		local victimaggro = victim:GetNWString("aggression")
		local killeraggro = killer:GetNWString("aggression")
		
		if killer:IsPlayer() then
			if CheckPos( killer ) == "earth" then
				if victimaggro == "aggression" then
					if killeraggro != "aggression" then
						if killeraggro != "global" then
							GlobalAggression( killer )
						else
							ResetTimer( killer )
						end
					end
				elseif ( killeraggro != "global" and victimaggro == "none" ) then
					GlobalAggression( killer ) 
				elseif ( killeraggro == "global" and victimaggro == "none" ) then
					ResetTimer( killer )
				end
			end
		end
				
		if victimaggro != "none" then
			ResetAggression( victim )
		end
	end
	
end

function PlayerDisconnect( ply )
	
	if ply:GetNWString("aggression") != "none" then
		ResetAggression( ply )
	end
	
end

timer.Create( "AggressionTimer", 1, 0, CheckAggressionTimer )
timer.Create( "CheckPos", 5, 0, CheckPos )

hook.Add( "PlayerSay", "AgroTable", AgroTable )
hook.Add( "PlayerDeath", "CheckAggression", PlayerDied )
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", FirstSpawn )
hook.Add( "PlayerDisconnected", "PlayerLeft", PlayerDisconnect )