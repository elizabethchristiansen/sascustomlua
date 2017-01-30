if not CLIENT then return end

function GetShield( ent )
	local s = ent:GetNWFloat("ShieldHP")
	local sm = ent:GetNWFloat("ShieldMAX")
	local sp = round( s/sm*100 )
	
	return s, sm, sp
end

function GetArmor( ent )
	local a = ent:GetNWFloat("ArmorHP")
	local am = ent:GetNWFloat("ArmorMAX")
	local ap = round( a/am*100 )
	
	return a, am, ap
end

function GetHull( ent )
	local h = ent:GetNWFloat("HullHP")
	local hm = ent:GetNWFloat("HullMAX")
	local hp = round( h/hm*100 )
	
	return h, hm, hp
end

function PaintInfo()
	
	local ply = LocalPlayer()
	local usehud = ply:GetNWBool( "scinfo" )
	
	if usehud == true then
		local v = ply:GetNWBool( "invehicle" )
		if v == true then
			local core = ply:GetNWEntity( "core" )
		
			local s, sm, sp = GetShield( core )
			local a, am, ap = GetArmor( core )
			local h, hm, hp = GetHull( core )
end

hook.Add("HUDPaint", "ShowSCInfo", PaintInfo)