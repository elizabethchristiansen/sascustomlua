AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_energy_upgrade(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_energy_upgrade" ) ) then return nil end
		
	local Core = ents.Create("sc_energy_upgrade")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_energy_upgrade", Core )
		
	return Core
end

function ENT:Setup( type, ply )

	local CM = SC_ETSCCM()

	local plyaccess = ply:GetNWInt( "accesslevel" )	
	
	self.type = type
	
	if type == "Cap Recharger" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0.85,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	10.00,
			PG = 	1.00
		}
		self.NameLable = type

	elseif type == "Micro Cap Battery" then
    	self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 38 * CM,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	5.00
		}
		self.NameLable = type

	elseif type == "Small Cap Battery" then
    	self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 75 * CM,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	50.00,
			PG = 	10.00
		}
		self.NameLable = type

	elseif type == "Medium Cap Battery" then
    	self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 300 * CM,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	75.00,
			PG = 	75.00
		}
		self.NameLable = type
		
	elseif type == "Large Cap Battery" then
    	self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 500 * CM,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	100.00,
			PG = 	250.00
		}
		self.NameLable = type

	elseif type == "Cap Power Relay" then
    	self.BaseEnergyBonus = {   	
			CRE 	= 0.80,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0.90,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	4.00,
			PG = 	0.00
		}
		self.NameLable = type

	elseif type == "Cap Flux Coil" then
 		self.BaseEnergyBonus = {   	
			CRE 	= 0.80,
			CAP		= 0,
			CAPP	= 0.90,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	20.00,
			PG = 	0.00
		}
		self.NameLable = type

	elseif type == "Power Diagnostic" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0.925,
			CAP		= 0,
			CAPP	= 1.04,
			SRE 	= 0.925,
			SHLD 	= 1.04,
			PG		= 1.05,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	20.00,
			PG = 	0.00
		}
		self.NameLable = type
		
	elseif type == "Shield Recharger" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0.90,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	1.00
		}
		self.NameLable = type
		
	elseif type == "Shield Power Relay" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 1.35,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0.80,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	20.00,
			PG = 	0.00
		}
		self.NameLable = type
		
	elseif type == "Shield Flux Coil" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0.75,
			SHLD 	= 0.85,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	20.00,
			PG = 	0.00
		}
		self.NameLable = type 
	elseif type == "Co-Processor" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 1.07 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	0.00,
			PG = 	1.00
		}
		self.NameLable = type 
	elseif type == "Reactor Control" then
  		self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 1.10,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	20.00,
			PG = 	0.00
		}
		self.NameLable = type		
		
	elseif type == "[Concord] Energy Systems Enhancer" and plyaccess >= GetConVar( "access_ship_core_conc" ):GetInt() then
		self.BaseEnergyBonus = {   	
			CRE 	= 0.75,
			CAP		= 0,
			CAPP	= 1.10,
			SRE 	= 0.75,
			SHLD 	= 1.10,
			PG		= 1.10,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	30.00,
			PG = 	0.00
		}
		self.NameLable = "[Concord] Energy Systems Enhancer"

	elseif type == "[Jove] Energy Systems Enhancer" and plyaccess >= GetConVar( "access_ship_core_jove" ):GetInt() then
		self.BaseEnergyBonus = {   	
			CRE 	= 0.625,
			CAP		= 0,
			CAPP	= 1.225,
			SRE 	= 0.625,
			SHLD 	= 1.225,
			PG		= 1.225,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	40.00,
			PG = 	0.00
		}
		self.NameLable = "[Jove] Energy Systems Enhancer"
		
		
	elseif type == "[Polaris] Energy Systems Enhancer" and plyaccess >= GetConVar( "access_ship_core_polaris" ):GetInt() then
		self.BaseEnergyBonus = {   	
			CRE 	= 0.20,
			CAP		= 0,
			CAPP	= 0.70,
			SRE 	= 0.20,
			SHLD 	= 0.70,
			PG		= 1.25,
			CPU		= 1.25 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	30.00,
			PG = 	0.00
		}
		self.NameLable = "[Polaris] Energy Systems Enhancer"

	else
		self.BaseEnergyBonus = {   	
			CRE 	= 0,
			CAP		= 0,
			CAPP	= 0,
			SRE 	= 0,
			SHLD 	= 0,
			PG		= 0,
			CPU		= 0 	 	
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	30.00,
			PG = 	0.00
		}
		self.NameLable = "Fail"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_energy_upgrade", Make_sc_energy_upgrade, "Pos", "Ang","type")

function ENT:Initialize()
	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetUseType(SIMPLE_USE)  
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end 
		
	self.SC_Status = "Offline"
	self.SC_Immune2 = true
			 						
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100 	
	local ent = ents.Create( "sc_energy_upgrade" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate() 
		ent:Setup()
	return ent
end

function ENT:OnRemove()
	
end
 
function ENT:Use()
	print(tostring(self.testv1))
end 

function ENT:Think()
	self.BaseClass.Think(self)
	
	if not self.SC_CoreEnt then self.SC_Status = "Offline" end
	
	if not self.BaseEnergyBonus.CRE then self.BaseEnergyBonus.CRE = 0 end 
	if not self.BaseEnergyBonus.CAP then self.BaseEnergyBonus.CAP = 0 end 
	if not self.BaseEnergyBonus.CAPP then self.BaseEnergyBonus.CAPP = 0 end 
	if not self.BaseEnergyBonus.SRE then self.BaseEnergyBonus.SRE = 0 end 
	if not self.BaseEnergyBonus.SHLD then self.BaseEnergyBonus.SHLD = 0 end 
	if not self.BaseEnergyBonus.PG then self.BaseEnergyBonus.PG = 0 end 
	if not self.BaseEnergyBonus.CPU then self.BaseEnergyBonus.CPU = 0 end 
	
	self.SC_EnergyBonus = {
		CRE 	= self.BaseEnergyBonus.CRE * 1.00,
		CAP		= self.BaseEnergyBonus.CAP * 1.00,
		CAPP	= self.BaseEnergyBonus.CAPP * 1.00,
		SRE 	= self.BaseEnergyBonus.SRE * 1.00,
		SHLD 	= self.BaseEnergyBonus.SHLD * 1.00,
		PG		= self.BaseEnergyBonus.PG * 1.00,
		CPU		= self.BaseEnergyBonus.CPU * 1.00
	} 	
	
	local reslab = ""
	if self.SC_EnergyBonus.CRE > 0 then
		reslab = reslab.."Cap Recharge: "..tostring(self.SC_EnergyBonus.CRE*100-100).."%".."\n"
	end
	if self.SC_EnergyBonus.CAP > 0 then
		reslab = reslab.."Cap Capacity: "..tostring(self.SC_EnergyBonus.CAP).."\n"
	end
	if self.SC_EnergyBonus.CAPP > 0 then
		reslab = reslab.."Cap Capacity: "..tostring(self.SC_EnergyBonus.CAPP*100-100).."\n"
	end
	if self.SC_EnergyBonus.SRE > 0 then
		reslab = reslab.."Shield Recharge: "..tostring(self.SC_EnergyBonus.SRE*100-100).."%".."\n"
	end
	if self.SC_EnergyBonus.SHLD > 0 then
		reslab = reslab.."Shield Capacity: "..tostring(self.SC_EnergyBonus.SHLD*100-100).."%".."\n"
	end
	if self.SC_EnergyBonus.PG > 0 then
		reslab = reslab.."PG: "..tostring(self.SC_EnergyBonus.PG*100-100).."%".."\n"
	end
	if self.SC_EnergyBonus.CPU > 0 then
		reslab = reslab.."CPU: "..tostring(self.SC_EnergyBonus.CPU*100-100).."%".."\n"
	end
	
	
	self:SetOverlayText(self.NameLable.."\n"..
	reslab.."\n"..
	"-Fitting-".."\n"..
	"Slot: "..tostring(self.SC_Fitting.Slot).."\n"..
	"CPU: "..tostring(self.SC_Fitting.CPU).."\n"..
	"PG: "..tostring(self.SC_Fitting.PG).."\n"..
	"Status: "..self.SC_Status	
	)
	
	
end


function ENT:OnRestore()
    Wire_Restored( self )
end

function ENT:BuildDupeInfo()	
	local Info = WireLib.BuildDupeInfo( self.Entity )
	
	if Info == nil then
		Info = {}
	end
	
	local function frombool( Value )	
		if util.tobool( Value ) then 
			return 1 
		else 
			return 0 
		end
	end
	
	Info.type	= self.type 
    
	return Info
end

function ENT:ApplyDupeInfo( Player, Entity, Info, GetEntByID )
	self:Setup( Info.type, Player )
	self.Owner = Player
	
	WireLib.ApplyDupeInfo( Player, Entity, Info, GetEntByID )		
end

function ENT:PreEntityCopy()
	local DupeInfo = self:BuildDupeInfo()
	if DupeInfo then
		duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
	end
end

function ENT:PostEntityPaste( Player, Entity, CreatedEntities )
	if Entity.EntityMods and Entity.EntityMods.WireDupeInfo then
		Entity:ApplyDupeInfo( Player, Entity, Entity.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end )
	end
end




