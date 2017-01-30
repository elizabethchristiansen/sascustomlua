AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_shield_repair(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_shield_repair" ) ) then return nil end
		
	local Core = ents.Create("sc_shield_repair")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_shield_repair", Core )
		
	return Core
end

function ENT:Setup( type, ply )
	local M = SC_ETSCM()
	local CM = SC_ETSCCM()
	local CSM = 2.5

	self.type = type
	
	if type == "Micro Shield Booster" then
  		self.BaseShieldRep = {
  			HP		= 23.00 * M,
  			CAP		= 20.00 * CM,
  			DUR		= 2.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	25.00,
			PG = 	2.00
		}
		self.NameLable = type

	elseif type == "Small Shield Booster" then
  		self.BaseShieldRep = {
  			HP		= 68.00 * M,
  			CAP		= 60.00 * CM,
  			DUR		= 3.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	50.00,
			PG = 	12.00
		}
		self.NameLable = type

	elseif type == "Medium Shield Booster" then
    	self.BaseShieldRep = {
  			HP		= 180.00 * M,
  			CAP		= 160.00 * CM,
  			DUR		= 4.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	100.00,
			PG = 	150.00
		}
		self.NameLable = type
		
	elseif type == "Large Shield Booster" then
    	self.BaseShieldRep = {
  			HP		= 450.00 * M,
  			CAP		= 400.00 * CM,
  			DUR		= 5.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	200.00,
			PG = 	500.00
		}
		self.NameLable = type
		
	elseif type == "Capital Shield Booster" then
    	self.BaseShieldRep = {
  			HP		= 7200.00 * CSM,
  			CAP		= 2400.00 * CM,
  			DUR		= 10.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	300.00,
			PG = 	75000.00
		}
		self.NameLable = type

	else
		self.BaseShieldRep = {
  			HP		= 6.00 * M,
  			CAP		= 5.00 * CM,
  			DUR		= 3.00
		}
		self.SC_Fitting = {
			Slot = 	"MED",
			CPU = 	2.00,
			PG = 	1.00
		}
		self.NameLable = "Civilain Shield Booster"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_shield_repair", Make_sc_shield_repair, "Pos", "Ang","type")

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
	local ent = ents.Create( "sc_shield_repair" )
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
	
	self.SC_ShieldRep = {
		REP		= self.BaseShieldRep.HP * 1.00,
  		CAP		= self.BaseShieldRep.CAP * 1.00,
  		DUR		= self.BaseShieldRep.DUR * 1.00
	} 	
	
	self:SetOverlayText(self.NameLable.."\n"..
	"Repaired: "..sc_ds(self.SC_ShieldRep.REP).."\n"..
	"Activation Cost: "..sc_ds(self.SC_ShieldRep.CAP).."\n"..
	"Duration: "..sc_ds(self.SC_ShieldRep.DUR).."\n"..
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
		if self.SC_CoreEnt.Cap.CAP >= self.SC_ShieldRep.CAP then
		    self.SC_CoreEnt:ConsumeCap(self.SC_ShieldRep.CAP)
			self.Cyclen = true
			self.CycleDone = false 
			self.NextCycle = CurTime() + self.SC_ShieldRep.DUR
			self.SC_CoreEnt:RepairShield(self.SC_ShieldRep.REP)
			scMsg("Took cap and Giveing Shield")
		else 
			scMsg("Shield: Not Enough Cap for cycle")
			--self.SC_Active = false
			return false
		end
	elseif self.SC_Active == false and self.Cyclen == false then
		self.Cyclen = false
		self.CycleDone = false
		self.CycleP = 0  		
		return false
	end
	    	
	self.CycleP = math.Round( (1-((self.NextCycle - CurTime()) / (self.SC_ShieldRep.DUR))) * 100 )
	
	Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
	
	if self.NextCycle <= CurTime() then
		self.CycleDone = true
		self.Cyclen = false
		self.CycleP = 100
		Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
		scMsg("Cycle done")
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




