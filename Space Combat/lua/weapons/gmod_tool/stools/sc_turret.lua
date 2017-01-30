TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Turrets"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_turret" ] = "Small_Pulse_Laser"

if ( CLIENT ) then
    language.Add( "Tool_sc_turret_name", "Turret Creation Tool" )
    language.Add( "Tool_sc_turret_desc", "Spawns a turret." )
    language.Add( "Tool_sc_turret_0", "Primary: Create/Update turret" )
	language.Add( "sboxlimit_sc_turret", "You've hit the turret limit!" )
	language.Add( "undone_sc_turret", "Undone turret" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_turret',99)
end

cleanup.Register( "sc_turret" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_turret" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_turret" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_turret") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_turret" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_turret( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_turret")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_turret", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_turret_Types", "Small Pulse Laser" )
list.Add( "sc_turret_Types", "Medium Pulse Laser" )
list.Add( "sc_turret_Types", "Large Pulse Laser" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_turret_name", Description = "#Tool_sc_turret_desc" })
	
	local Options = list.Get( "sc_turret_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_turret_sc_turret = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_turret_name", Height = "400", Options = RealOptions} )
end
	
