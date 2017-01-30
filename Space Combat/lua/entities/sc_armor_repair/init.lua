AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function Make_sc_armor_repair(pl, Pos, Ang, type)
	if ( !pl:CheckLimit( "sc_armor_repair" ) ) then return nil end
		
	local Core = ents.Create("sc_armor_repair")
		
	Core:SetPos(Pos)
	Core:SetAngles(Ang)
	Core:Spawn()
	Core:Activate()
	Core:Setup(type, pl)

	Core.Owner = pl

	pl:AddCount( "sc_armor_repair", Core )
		
	return Core
end

function ENT:Setup( type, ply )
	local M = SC_ETSCM()
	local CM = SC_ETSCCM()
	local CSM = 2.5

	self.type = type
	
	if type == "Micro Armor Repair" then
  		self.BaseArmorRep = {
  			HP		= 30.00 * M,
  			CAP		= 20.00 * CM,
  			DUR		= 4.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	3.00,
			PG = 	2.00
		}
		self.NameLable = type
	elseif type == "Small Armor Repair" then
  		self.BaseArmorRep = {
  			HP		= 60.00 * M,
  			CAP		= 40.00 * CM,
  			DUR		= 6.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	5.00,
			PG = 	5.00
		}
		self.NameLable = type

	elseif type == "Medium Armor Repair" then
    	self.BaseArmorRep = {
  			HP		= 240.00 * M,
  			CAP		= 160.00 * CM,
  			DUR		= 12.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	25.00,
			PG = 	150.00
		}
		self.NameLable = type
		
	elseif type == "Large Armor Repair" then
    	self.BaseArmorRep = {
  			HP		= 600.00 * M,
  			CAP		= 400.00 * CM,
  			DUR		= 15.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	50.00,
			PG = 	2000.00
		}
		self.NameLable = type
		
	elseif type == "Capital Armor Repair" then
    	self.BaseArmorRep = {
  			HP		= 9600.00 * CSM,
  			CAP		= 2400.00 * CM,
  			DUR		= 30.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	75.00,
			PG = 	125000.00
		}
		self.NameLable = type

	else
		self.BaseArmorRep = {
  			HP		= 15.00 * M,
  			CAP		= 10.00 * CM,
  			DUR		= 9.00
		}
		self.SC_Fitting = {
			Slot = 	"LOW",
			CPU = 	1.00,
			PG = 	2.00
		}
		self.NameLable = "Civilain Armor Repair"

	end
	
	self.SC_Status = "Offline"	

end

duplicator.RegisterEntityClass("sc_armor_repair", Make_sc_armor_repair, "Pos", "Ang","type")

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
	local ent = ents.Create( "sc_armor_repair" )
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
	
	self.SC_ArmorRep = {
		REP		= self.BaseArmorRep.HP * 1.00,
  		CAP		= self.BaseArmorRep.CAP * 1.00,
  		DUR		= self.BaseArmorRep.DUR * 1.00
	} 	
	
	self:SetOverlayText(self.NameLable.."\n"..
	"Repaired: "..sc_ds(self.SC_ArmorRep.REP).."\n"..
	"Activation Cost: "..sc_ds(self.SC_ArmorRep.CAP).."\n"..
	"Duration: "..sc_ds(self.SC_ArmorRep.DUR).."\n"..
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
		if self.SC_CoreEnt.Cap.CAP >= self.SC_ArmorRep.CAP then		
		    self.SC_CoreEnt:ConsumeCap(self.SC_ArmorRep.CAP)
			self.Cyclen = true
			self.CycleDone = false 
			self.NextCycle = CurTime() + self.SC_ArmorRep.DUR
			scMsg("Took cap and started cycle")
		else 
			scMsg("Armor: Not Enough Cap for cycle")
			--self.SC_Active = false
			return false
		end
	elseif self.SC_Active == false and self.Cyclen == false then
		self.Cyclen = false
		self.CycleDone = false
		self.CycleP = 0  		
		return false
	end
	    	
	self.CycleP = math.Round( (1-((self.NextCycle - CurTime()) / (self.SC_ArmorRep.DUR))) * 100 )
	
	Wire_TriggerOutput(self.Entity, "Cycle %", self.CycleP)
	
	if self.NextCycle <= CurTime() then
		self.SC_CoreEnt:RepairArmor(self.SC_ArmorRep.REP)
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




