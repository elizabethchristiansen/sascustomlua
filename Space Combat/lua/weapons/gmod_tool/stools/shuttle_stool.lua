TOOL.Category		= "Ship Cores"
TOOL.Name			= "Shuttle"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if ( CLIENT ) then
    language.Add( "Tool_shuttle_name", "Shuttle Creation Tool" )
    language.Add( "Tool_shuttle_desc", "Turns a prop into a Shuttle." )
    language.Add( "Tool_shuttle_0", "Primary: Create/Update Shuttle" )
	language.Add( "sboxlimit_shuttle", "You've hit the Shuttle limit!" )
	language.Add( "undone_shuttle", "Undone Shuttle" )
end

if (SERVER) then
  CreateConVar('sbox_maxshuttle',3)
end

TOOL.Model = "models/props_lab/powerbox02d.mdl"

cleanup.Register( "shuttle" )

function TOOL:LeftClick(trace)
	if (!trace.HitPos) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if ( CLIENT ) then return true end
	if (!trace.Entity:IsValid()) then return false end
	if (trace.Entity:GetClass() != "shuttle_B" and trace.Entity:GetClass() != "prop_physics") then return false end

	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "shuttle_B" && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "shuttle" ) ) then return false end

	local Ang = trace.Entity:GetAngles()
	local Pos =	trace.Entity:GetPos()
	local Mdl =	trace.Entity:GetModel()

	Msg("\n"..tostring(trace.Entity).."\n")
	local shuttle = MakeShuttle( ply, Pos, Ang, Mdl )
	trace.Entity:Remove()

	undo.Create("shuttle")
		undo.AddEntity( shuttle )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "shuttle", shuttle )

	return true
	
end

if SERVER then

	function MakeShuttle(pl, Pos, Ang, Mdl)
		if (!pl:CheckLimit("shuttle")) then return end

		local shuttle = ents.Create("shuttle_B")
		shuttle:SetPos(Pos)
		shuttle:SetAngles(Ang)
		shuttle:SetModel( Mdl )
		shuttle:Spawn()
		shuttle:Activate()

		pl:AddCount( "shuttle", shuttle )
		
		return shuttle
	end

	--duplicator.RegisterEntityClass("gmod_wire_locator", MakeWireLocator, "Pos", "Ang", "Vel", "aVel", "frozen", "nocollide")

end

function TOOL:UpdateGhostWireLocator( ent, player )

	ent:SetNoDraw( true )

end

function TOOL:Think()

end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_shuttle_name", Description = "#Tool_shuttle_desc" })
end
	
