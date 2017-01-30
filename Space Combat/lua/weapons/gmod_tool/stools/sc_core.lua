TOOL.Category		= "Ship Cores"
TOOL.Name			= "#Ship Cores"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.ClientConVar[ "core" ] = "Amarr Core"

if ( CLIENT ) then
    language.Add( "Tool_sc_core_name", "Ship Core Creation Tool" )
    language.Add( "Tool_sc_core_desc", "Turns a prop into a Ship Core." )
    language.Add( "Tool_sc_core_0", "Primary: Create/Update Ship Core" )
	language.Add( "sboxlimit_sc_core", "You've hit the Ship Core limit!" )
	language.Add( "undone_sc_core", "Undone Ship Core" )
end

if (SERVER) then
	CreateConVar('sbox_maxsc_core',4)
end

cleanup.Register( "sc_core" )

function TOOL:LeftClick(trace)
    local type	= self:GetClientInfo( "core" )
	Msg("Type: "..tostring(type).."\n")
    Msg("STOOL Trace hit: "..tostring(trace.Entity).."\n")
	if (!trace.HitPos) then Msg("FAIL STOOL\n") return false end
	if (trace.Entity:IsPlayer()) then Msg("FAIL STOOL2\n") return false end
	if ( CLIENT ) then Msg("FAIL STOOL3\n") return true end
	if (!trace.Entity:IsValid()) then Msg("FAIL STOOL4\n") return false end
	if (trace.Entity:GetClass() != "prop_physics") then Msg("FAIL STOOL5\n") return false end
	
	local ply = self:GetOwner()
	
	if ( trace.Entity:IsValid() && string.find(trace.Entity:GetClass(), "ship_core") && trace.Entity.pl == ply ) then
		return true
	end	

	if ( !self:GetSWEP():CheckLimit( "sc_core" ) ) then return false end

	local Ang = trace.Entity:GetAngles()
	local Pos =	trace.Entity:GetPos()
	local Mdl =	trace.Entity:GetModel()
	
	Msg("\n"..tostring(trace.Entity).."\n")
	local Core = MakeSCCore( ply, Pos, Ang, Mdl, type)
	trace.Entity:Remove()

	undo.Create("sc_core")
		undo.AddEntity( Core )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "sc_core", Core )

	return true
	
end

if SERVER then

	function MakeSCCore(pl, Pos, Ang, Mdl, type)
		if ( !pl:CheckLimit( "sc_core" ) ) then return nil end
		
		local plyaccess = pl:GetNWInt( "accesslevel" )
		
		local Core = ents.Create("ship_core_base")

		if type == "Amarr Core" then
  			Core = ents.Create("ship_core_amarr")
		elseif type == "Caldari Core" then
		    Core = ents.Create("ship_core_caldari")
		elseif type == "Gallente Core" then
		    Core = ents.Create("ship_core_gallente")
		elseif type == "Minmatar Core" then
			Core = ents.Create("ship_core_minmatar")
		elseif type == "Concord Core" and plyaccess >= GetConVar( "access_ship_core_conc" ):GetInt() then
		    Core = ents.Create("ship_core_conc")
		elseif type == "Jovian Core" and plyaccess >= GetConVar( "access_ship_core_jove" ):GetInt() then
			Core = ents.Create("ship_core_jove")
		elseif type == "Polaris Core" and plyaccess >= GetConVar( "access_ship_core_polaris" ):GetInt() then
			Core = ents.Create("ship_core_polaris")
		else
		    Core = ents.Create("ship_core_caldari")
		end
		
		Core:SetPos(Pos)
		Core:SetAngles(Ang)
		Core:SetModel(Mdl)
		Core:Spawn()
		Core:Activate()
		
		Core.ConWeldTable = {}
		Core.Owner = pl

		pl:AddCount( "sc_core", Core )
		
		return Core
	end

end

function TOOL:Think()

end

list.Add( "SC_Core_Types", "Amarr Core" )
list.Add( "SC_Core_Types", "Caldari Core" )
list.Add( "SC_Core_Types", "Gallente Core" )
list.Add( "SC_Core_Types", "Minmatar Core" )
list.Add( "SC_Core_Types", "Concord Core" )
list.Add( "SC_Core_Types", "Jovian Core" )
list.Add( "SC_Core_Types", "Polaris Core" )

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", { Text = "#Tool_sc_core_name", Description = "#Tool_sc_core_desc" })
	
	local Options = list.Get( "SC_Core_Types" )
	
	local RealOptions = {}

	for k, v in pairs( Options ) do
		RealOptions[ v ] = { SC_Core_core = v }
	end
	
	CPanel:AddControl( "ListBox", { Label = "#Tool_sc_core_name", Height = "150", Options = RealOptions} )
end
	
