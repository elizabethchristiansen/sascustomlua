TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Weapon Upgrades"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "sc_weapon_upgrade" ] = "Heat Sink I"

if ( CLIENT ) then
    language.Add( "Tool_sc_weapon_upgrade_name", "Weapon Upgrade Creation Tool" )
    language.Add( "Tool_sc_weapon_upgrade_desc", "Spawns An Weapon Upgrade." )
    language.Add( "Tool_sc_weapon_upgrade_0", "Primary: Create/Update Weapon Upgrade" )
	language.Add( "sboxlimit_sc_weapon_upgrade", "You've hit the Weapon Upgrade limit!" )
	language.Add( "undone_sc_weapon_upgrade", "Undone Weapon Upgrade" )
end

if (SERVER) then
  CreateConVar('sbox_maxsc_weapon_upgrade',99)
end

cleanup.Register( "sc_weapon_upgrade" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "sc_weapon_upgrade" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	--if (trace.Entity:GetClass() != "prop_physics") then
	if trace.Entity:GetClass() == "sc_weapon_upgrade" then
		local ent =  trace.Entity
		ent:Setup(type,self:GetOwner())
		return true --Stop it from going on to stuff below and making new ent
	end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "sc_weapon_upgrade") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_weapon_upgrade" ) ) then return false end

	--local Ang = trace.Entity:GetAngles()
	--local Pos =	trace.Entity:GetPos()
	local Ang = trace.HitNormal:Angle() + Angle(90,0,0)
	local Pos = trace.HitPos + trace.HitNormal * 4
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = Make_sc_weapon_upgrade( ply, Pos, Ang, type, trace)
	
	local phys = Core:GetPhysicsObject()
	if (phys:IsValid() and trace.Entity:IsValid() ) then
		local weld = constraint.Weld(Core, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(Core, trace.Entity, 0, trace.PhysicsBone)
	end

	undo.Create("sc_weapon_upgrade")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_weapon_upgrade", Core )

	return true
	
end


function TOOL:Think()

end

list.Add( "sc_weapon_upgrade_Types", "Tracking Enhancer I" )
list.Add( "sc_weapon_upgrade_Types", "Tracking Computer I" )
list.Add( "sc_weapon_upgrade_Types", "Heat Sink I" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_weapon_upgrade_name", Description = "#Tool_sc_weapon_upgrade_desc" })
	
	local Options = list.Get( "sc_weapon_upgrade_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { sc_weapon_upgrade_sc_weapon_upgrade = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_weapon_upgrade_name", Height = "400", Options = RealOptions} )
end
	
