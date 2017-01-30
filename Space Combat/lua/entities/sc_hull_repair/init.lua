AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_hull_repair(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_hull_repair" ) ) then return nil end
		
	local Core = ents.Create("sc_hull_repair")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_hull_repair", Core )
		
	return Core
end

function ENT:Setup( type, ply )
	local M = SC_ETSCM()
	local CM = SC_ETSCCM()
	local CSM = 2.5
	local DM = 0.5

	self.type = type

	if type == "Small Hull Repair" then
  		self.BaseHullRep = {
  			HP		= 25.00 * M,
  			CAP		= 30.00 * CM,
  			DUR		= 30.00 * DM
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	30.00,
			PG = 	10.00
		}
		self.NameLable = type

	elseif type == "Medium Hull Repair" then
    	self.BaseHullRep = {
  			HP		= 50.00 * M,
  			CAP		= 60.00 * CM,
  			DUR		= 30.00 * DM
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	60.00,
			PG = 	50.00
		}
		self.NameLable = type
		
	elseif type == "Large Hull Repair" then
    	self.BaseHullRep = {
  			HP		= 100.00 * M,
  			CAP		= 120.00 * CM,
  			DUR		= 30.00 * DM
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	125.00,
			PG = 	250.00
		}
		self.NameLable = type

	else
		self.BaseHullRep = {
  			HP		= 10.00 * M,
  			CAP		= 15.00 * CM,
  			DUR		= 30.00 * DM
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	1.00,
			PG = 	2.00
		}
		self.NameLable = "Civilain Hull Repair"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_hull_repair", Make_sc_hull_repair, "Pos", "Ang","type")

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
	
	self.Outputs = Wire_CreateOutputs( self.Entity, { 
		"Cycle %"
	} )
	
	self.Inputs = Wire_CreateInputs( self.Entity, { 
		"On"
	} )
	
	self.SC_Active = false
	self.NextCycle = CurTime() 
	self.Cyclen = false
	self.CycleP = 0
	self.CycleDone = false
			 						
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end    	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100 	
	local ent = ents.Create( "sc_hull_repair" )
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
	
	self.SC_HullRep = {
		REP		= self.BaseHullRep.HP * 1.00,
  		CAP		= self.BaseHullRep.CAP * 1.00,
  		DUR		= self.BaseHullRep.DUR * 1.00
	} 	
	
	self:SetOverlayText(self.NameLable.."\n"..
	"Repaired: "..sc_ds(self.SC_HullRep.REP).."\n"..
	"Activation Cost: "..sc_ds(self.SC_HullRep.CAP).."\n"..
	"Duration: "..sc_ds(self.SC_HullRep.DUR).."\n"..
	"Cycle %: "..tostring(self.CycleP).."\n"..
	"-Fitting-".."\n"..
	"CPU: "..tostring(self.SC_Fitting.CPU).."\n"..
	"PG: "..sc_ds(self.SC_Fitting.PG).."\n"..
	"Status: "..self.SC_Status	
	)
	
	if self.SC_Active == true or self.Cyclen == true then 
		self:SC_Cycle() 
	end
	if self.SC_Active == false and self.Cyclen == false then 
		self.CycleP = 0 
		Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
	end
	
end

function ENT:SC_Cycle()
	if not self.SC_CoreEnt then self.CycleP = 0 return false end
	
	if self.SC_Active == true and self.Cyclen == false then
		if self.SC_CoreEnt.Cap.CAP >= self.SC_HullRep.CAP then
      		self.SC_CoreEnt:ConsumeCap(self.SC_HullRep.CAP)
			self.Cyclen = true
			self.CycleDone = false 
			self.NextCycle = CurTime() + self.SC_HullRep.DUR
			scMsg("Took cap and started cycle")
		else 
			scMsg("Hull: Not Enough Cap for cycle")
			--self.SC_Active = false
			return false
		end
	elseif self.SC_Active == false and self.Cyclen == false then
		self.Cyclen = false
		self.CycleDone = false
		self.CycleP = 0  		
		return false
	end
	    	
	self.CycleP = math.Round( (1-((self.NextCycle - CurTime()) / (self.SC_HullRep.DUR))) * 100 )
	
	Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
	
	if self.NextCycle <= CurTime() then
		self.SC_CoreEnt:RepairHull(self.SC_HullRep.REP)
		self.CycleDone = true
		self.Cyclen = false
		self.CycleP = 100
		Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
		scMsg("Cycle done, Giveing Armor") 		
	end 

end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		if value == 1 then
			self.SC_Active = true
			self:SC_Cycle() 
		else
		 	self.SC_Active = false  
		end		
	end
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